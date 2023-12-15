%lang starknet

@contract_interface
namespace IRandomNumberGenerator:
    func commit(hash: felt):
    end

    func reveal(secret: felt) -> (random_number: felt):
    end
end

@storage_var
func user_commit(user: felt) -> (commit: felt):
end

@storage_var
func nonce() -> (value: felt):
end

@external
func commit(hash: felt):
    let caller_address = get_caller_address()
    user_commit.write(caller_address, hash)
    return ()

@external
func reveal(secret: felt) -> (random_number: felt):
    let caller_address = get_caller_address()
    let commit_hash = user_commit.read(caller_address)

    assert hash_secret(secret) = commit_hash, "Invalid secret"

    let current_nonce = nonce.read()
    let block_number = get_block_number()
    let block_timestamp = get_block_timestamp()

    let combined = block_number + block_timestamp + secret + current_nonce
    let random_number = bitwise_and(combined, (2**250) - 1)

    nonce.write(current_nonce + 1)

    // Emit an event or handle the random number as needed
    return (random_number,)
end

func hash_secret(secret: felt) -> (hash: felt):
    // Implement hashing logic using Pedersen hash
    return (hash,)
