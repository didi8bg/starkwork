%lang starknet

@contract_interface
namespace IRandomNumberGenerator:
    func generate_random_number() -> (random_number: felt):
    end
end

@storage_var
func nonce() -> (value: felt):
end

@external
func generate_random_number() -> (random_number: felt):
    let current_nonce = nonce.read()
    let block_number = get_block_number()
    let block_timestamp = get_block_timestamp()

    let random_seed = block_number + block_timestamp + current_nonce
    let random_number = bitwise_and(random_seed, (2**250) - 1)

    nonce.write(current_nonce + 1)
    return (random_number,)
end
