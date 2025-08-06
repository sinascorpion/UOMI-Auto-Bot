using Printf
using Dates
using Random
using HTTP
using JSON
using DotEnv
using SHA

# Initialize environment variables
DotEnv.config()

# Configuration
const RPC_URL = get(ENV, "RPC_URL", "https://finney.uomi.ai")
const PRIVATE_KEY = get(ENV, "PRIVATE_KEY", "")
const WALLET = lowercase(get(ENV, "WALLET_ADDRESS", "")) # Julia uses lowercase for hex
const CHAIN_ID = 4386

const ROUTER_ADDRESS = lowercase("0x197EEAd5Fe3DB82c4Cd55C5752Bc87AEdE11f230")
const TOKENS = Dict(
    "SYN" => lowercase("0x2922B2Ca5EB6b02fc5E1EBE57Fc1972eBB99F7e0"),
    "SIM" => lowercase("0x04B03e3859A25040E373cC9E8806d79596D70686"),
    "USDC" => lowercase("0xAA9C4829415BCe70c434b7349b628017C59EC2b1"),
    "DOGE" => lowercase("0xb227C129334BC58Eb4d02477e77BfCCB5857D408"),
    "SYN_TO_UOMI" => lowercase("0x2922B2Ca5EB6b02fc5E1EBE57Fc1972eBB99F7e0"),
    "SIM_TO_UOMI" => lowercase("0x04B03e3859A25040E373cC9E8806d79596D70686"),
    "USDC_TO_UOMI" => lowercase("0xAA9C4829415BCe70c434b7349b628017C59EC2b1"),
    "DOGE_TO_UOMI" => lowercase("0xb227C129334BC58Eb4d02477e77BfCCB5857D408"),
    "UOMI_TO_WUOMI" => lowercase("0x5FCa78E132dF589c1c799F906dC867124a2567b2"),
    "WUOMI_TO_UOMI" => lowercase("0x5FCa78E132dF589c1c799F906dC867124a2567b2")
)

const ROUTER_ABI = [
    Dict(
        "inputs" => [
            Dict("internalType" => "bytes", "name" => "commands", "type" => "bytes"),
            Dict("internalType" => "bytes[]", "name" => "inputs", "type" => "bytes[]")
        ],
        "name" => "execute",
        "outputs" => [],
        "stateMutability" => "payable",
        "type" => "function"
    )
]

# Banner and Metadata
const BANNER = """
██╗   ██╗     ██████╗     ███╗   ███╗    ██╗
██║   ██║    ██╔═══██╗    ████╗ ████║    ██║
██║   ██║    ██║   ██║    ██╔████╔██║    ██║
██║   ██║    ██║   ██║    ██║╚██╔╝██║    ██║
╚██████╔╝    ╚██████╔╝    ██║ ╚═╝ ██║    ██║
 ╚═════╝      ╚═════╝     ╚═╝     ╚═╝    ╚═╝
"""

const VERSION = "Version 1.0 (Julia)"
const CREDIT = "LETS FUCK THIS TESTNET--Created By Kazuha"
const LAST_RUN_FILE = "last_run.txt"

# Helper Functions
function save_last_run()
    open(LAST_RUN_FILE, "w") do f
        write(f, Dates.format(now(), "yyyy-mm-dd HH:MM:SS"))
    end
end

function get_last_run()
    isfile(LAST_RUN_FILE) ? read(LAST_RUN_FILE, String) : "Never"
end

function center_text(text::String, width::Int=displaysize(stdout)[2])
    lines = split(strip(text), '\n')
    return join([rpad(lpad(line, (width - length(line)) ÷ 2 + length(line)), width) for line in lines], '\n')
end

function loading_animation(message::String, duration::Float64=1.5)
    width = displaysize(stdout)[2]
    frames = ["[◇◇◇◇]", "[◆◇◇◇]", "[◆◆◇◇]", "[◆◆◆◇]", "[◆◆◆◆]"]
    println("\n\033[36m$(center_text(message, width))\033[0m")
    for _ in 1:round(Int, duration * 2)
        for frame in frames
            print("\033[34m$(center_text(frame, width))\033[0m\r")
            sleep(0.2)
        end
    end
    println("\033[32m$(center_text("DONE", width))\033[0m")
end

function show_swap_menu()
    width = displaysize(stdout)[2]
    println("\n\033[37m\033[1m$(center_text("UOMI DEX Swap Terminal", width))\033[0m")
    println("\033[36m$(center_text("Wallet: $(WALLET[1:6])...$(WALLET[end-3:end]) | Time: $(Dates.format(now(), "HH:MM:SS dd-mm-yyyy"))", width))\033[0m")
    println("\033[34m$(center_text("-" ^ 50, width))\033[0m")
    println("\033[36m$(center_text("Swap Options:", width))\033[0m")
    for (i, token) in enumerate(keys(TOKENS))
        option = if endswith(token, "_TO_UOMI")
            "[$(i)] $(split(token, "_TO_")[1]) → UOMI"
        elseif token == "UOMI_TO_WUOMI"
            "[$(i)] UOMI → WUOMI"
        else
            "[$(i)] UOMI → $token"
        end
        println("\033[37m$(center_text(option, width))\033[0m")
    end
    println("\033[37m$(center_text("[$(length(TOKENS) + 1)] Auto Swap All Pairs", width))\033[0m")
    println("\033[34m$(center_text("-" ^ 50, width))\033[0m")
end

function do_swap(token_name::String, token_addr::String, is_token_to_uomi::Bool=false)
    width = displaysize(stdout)[2]
    amount = token_name == "UOMI_TO_WUOMI" ? BigInt(round(1e18 * rand(0.001:0.0001:0.004))) : BigInt(1e16) # 0.01 ether

    if token_name == "UOMI_TO_WUOMI"
        amount_display = amount / 1e18
        println("\n\033[37m\033[1m$(center_text("Initiating Swap: $(@sprintf("%.6f", amount_display)) UOMI → WUOMI", width))\033[0m")
        loading_animation("Preparing Transaction")
        try
            # Placeholder for JSON-RPC call (no native web3 in Julia)
            tx = Dict(
                "chainId" => CHAIN_ID,
                "from" => WALLET,
                "to" => token_addr,
                "value" => string(amount, base=16),
                "data" => "0xd0e30db0", # Deposit function selector
                "nonce" => get_nonce(WALLET), # Placeholder function
                "gas" => 42242,
                "maxFeePerGas" => get_base_fee() + 2 * 1e9, # 2 gwei
                "maxPriorityFeePerGas" => 2 * 1e9
            )
            signed_tx = sign_transaction(tx, PRIVATE_KEY) # Placeholder
            tx_hash = send_raw_transaction(signed_tx) # Placeholder
            println("\033[32m$(center_text("TX SENT: https://explorer.uomi.ai/tx/$tx_hash", width))\033[0m")
            println("\033[32m\033[1m$(center_text("SWAP EXECUTED", width))\033[0m")
        catch e
            println("\033[31m\033[1m$(center_text("SWAP ERROR: $(string(e)[1:min(50, length(string(e)))])...", width))\033[0m")
        end
        return
    end

    # Other swaps
    token_symbol = is_token_to_uomi ? split(token_name, "_TO_")[1] : token_name
    swap_display = is_token_to_uomi ? "0.01 $token_symbol → UOMI" : "0.01 UOMI → $token_symbol"
    println("\n\033[37m\033[1m$(center_text("Initiating Swap: $swap_display", width))\033[0m")
    
    if is_token_to_uomi
        loading_animation("Approving Token")
        try
            # Placeholder for ERC20 approve
            approve_tx = Dict(
                "from" => WALLET,
                "to" => token_addr,
                "data" => encode_approve(ROUTER_ADDRESS, amount), # Placeholder
                "nonce" => get_nonce(WALLET),
                "gas" => 100000,
                "maxFeePerGas" => get_base_fee() + 2 * 1e9,
                "maxPriorityFeePerGas" => 2 * 1e9
            )
            signed_approve = sign_transaction(approve_tx, PRIVATE_KEY)
            approve_tx_hash = send_raw_transaction(signed_approve)
            println("\033[32m$(center_text("APPROVED: https://explorer.uomi.ai/tx/$approve_tx_hash", width))\033[0m")
        catch e
            println("\033[31m\033[1m$(center_text("APPROVAL ERROR: $(string(e)[1:min(50, length(string(e)))])...", width))\033[0m")
            return
        end
    end

    # Swap execution
    loading_animation("Executing Swap")
    try
        commands = "0x00" # SWAP_EXACT_INPUT
        inputs = is_token_to_uomi ? [
            encode_swap(TOKENS[token_name], TOKENS["SYN"], 3000, WALLET, amount, 0, 0)
        ] : [
            encode_swap(TOKENS["SYN"], token_addr, 3000, WALLET, amount, 0, 0)
        ]
        tx = Dict(
            "chainId" => CHAIN_ID,
            "from" => WALLET,
            "to" => ROUTER_ADDRESS,
            "value" => is_token_to_uomi ? "0x0" : string(amount, base=16),
            "data" => encode_execute(commands, inputs), # Placeholder
            "nonce" => get_nonce(WALLET),
            "gas" => 300000,
            "maxFeePerGas" => get_base_fee() + 2 * 1e9,
            "maxPriorityFeePerGas" => 2 * 1e9
        )
        signed_tx = sign_transaction(tx, PRIVATE_KEY)
        tx_hash = send_raw_transaction(signed_tx)
        println("\033[32m$(center_text("TX SENT: https://explorer.uomi.ai/tx/$tx_hash", width))\033[0m")
        println("\033[32m\033[1m$(center_text("SWAP EXECUTED", width))\033[0m")
    catch e
        println("\033[31m\033[1m$(center_text("SWAP ERROR: $(string(e)[1:min(50, length(string(e)))])...", width))\033[0m")
    end
end

# Placeholder Blockchain Functions
function get_nonce(address::String)
    # Implement JSON-RPC call to eth_getTransactionCount
    return 0
end

function get_base_fee()
    # Implement JSON-RPC call to eth_getBlockByNumber
    return 1 * 1e9
end

function sign_transaction(tx::Dict, private_key::String)
    # Implement transaction signing (requires crypto library)
    return "0x" * randstring(64)
end

function send_raw_transaction(signed_tx::String)
    # Implement JSON-RPC call to eth_sendRawTransaction
    return "0x" * randstring(64)
end

function encode_approve(spender::String, amount::BigInt)
    # Placeholder for encoding ERC20 approve
    return "0x095ea7b3" * lpad(string(spender, base=16), 64, '0') * lpad(string(amount, base=16), 64, '0')
end

function encode_swap(token_in::String, token_out::String, fee::Int, recipient::String, amount::BigInt, amount_out_min::Int, sqrt_price_limit::Int)
    # Placeholder for encoding swap data
    return "0x" * randstring(64)
end

function encode_execute(commands::String, inputs::Vector)
    # Placeholder for encoding execute call
    return "0x" * randstring(64)
end

# Main Function
function main()
    width = displaysize(stdout)[2]
    println("\n\033[35m\033[1m$(center_text(BANNER))\033[0m")
    println("\033[35m\033[1m$(center_text(VERSION, width))\033[0m")
    println("\033[33m\033[1m$(center_text(CREDIT, width))\033[0m")
    println("\033[36m$(center_text("Last Run: $(get_last_run())", width))\033[0m")
    loading_animation("Initializing UOMI DEX Swap Terminal")
    save_last_run()

    while true
        show_swap_menu()
        print("\033[36m\033[1m$(center_text(">> Select Option: ", width))\033[0m")
        choice_input = readline()
        choice = tryparse(Int, choice_input)
        if isnothing(choice)
            println("\033[31m\033[1m$(center_text("ERROR: Enter a valid number", width))\033[0m")
            sleep(1.5)
            continue
        end

        token_list = collect(TOKENS)
        auto_all_option = length(TOKENS) + 1

        if choice == auto_all_option
            print("\033[36m\033[1m$(center_text(">> Number of Cycles: ", width))\033[0m")
            num_cycles = tryparse(Int, readline())
            if isnothing(num_cycles) || num_cycles <= 0
                println("\033[31m\033[1m$(center_text("ERROR: Enter a positive number", width))\033[0m")
                sleep(1.5)
                continue
            end
            for cycle in 1:num_cycles
                println("\n\033[37m\033[1m$(center_text("Cycle $cycle/$num_cycles", width))\033[0m")
                for (i, (token_name, token_addr)) in enumerate(token_list)
                    is_token_to_uomi = endswith(token_name, "_TO_UOMI")
                    pct = rand(0.10:0.01:0.15)
                    println("\033[36m$(center_text("[$i] $token_name: $(@sprintf("%.2f", pct*100))%", width))\033[0m")
                    do_swap(token_name, token_addr, is_token_to_uomi)
                    sleep(1.5)
                end
                loading_animation("Cycle Completed")
            end
            println("\033[32m\033[1m$(center_text("AUTO SWAP COMPLETED", width))\033[0m")
        elseif 1 <= choice <= length(token_list)
            token_name, token_addr = token_list[choice]
            is_token_to_uomi = endswith(token_name, "_TO_UOMI")
            print("\033[36m\033[1m$(center_text(">> Number of Swaps: ", width))\033[0m")
            num_swaps = tryparse(Int, readline())
            if isnothing(num_swaps) || num_swaps <= 0
                println("\033[31m\033[1m$(center_text("ERROR: Enter a positive number", width))\033[0m")
                sleep(1.5)
                continue
            end
            for i in 1:num_swaps
                pct = rand(0.10:0.01:0.15)
                println("\033[36m$(center_text("[$i/$num_swaps] $token_name: $(@sprintf("%.2f", pct*100))%", width))\033[0m")
                do_swap(token_name, token_addr, is_token_to_uomi)
                sleep(1.5)
            end
            println("\033[32m\033[1m$(center_text("SWAPS COMPLETED", width))\033[0m")
        else
            println("\033[31m\033[1m$(center_text("INVALID OPTION. EXITING.", width))\033[0m")
            break
        end
        println("\033[36m$(center_text("Returning to Terminal", width))\033[0m")
        loading_animation("Loading Terminal")
    end
end

# Run the script
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
