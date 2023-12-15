%lang starknet

@contract_interface
namespace IRandomNumberGenerator:
    func commit(hash: felt):
    end

    func reveal(secret: felt) -> (random_number: felt):
    end
end

@storage_var
func user_commit(user: felt) -> (commit: felt, commit_block: felt):
end

@storage_var
func nonce() -> (value: felt):
end

@external
func commit(hash: felt):
    let caller_address = get_caller_address()
    let current_block = get_block_number()

    // Store the commit hash along with the block number of the commit
    user_commit.write(caller_address, hash, current_block)
    return ()

@external
func reveal(secret: felt) -> (random_number: felt):
    let caller_address = get_caller_address()
    let (commit_hash, commit_block) = user_commit.read(caller_address)

    assert hash_secret(secret) = commit_hash, "Invalid secret"

    // Check if enough blocks have passed since the commit
    let current_block = get_block_number()
    assert current_block - commit_block > MIN_BLOCK_DELAY, "Too early to reveal"

    let current_nonce = nonce.read()

    // Use additional entropy sources for randomness
    let combined = current_block + secret + current_nonce + caller_address
    let random_number = bitwise_and(combined, (2**250) - 1)

    nonce.write(current_nonce + 1)

    // Emit an event or handle the random number as needed
    return (random_number,)
end

func hash_secret(secret: felt) -> (hash: felt):
    // Implement hashing logic using Pedersen hash
    return (hash,)
end

const MIN_BLOCK_DELAY = 10  # Define a minimum number of blocks delay for the reveal
