%lang starknet

@contract_interface
namespace IRandomNumberGenerator:
    func commit(user: felt, hash: felt):
    end

    func reveal(user: felt, secret: felt):
    end

    func generate_aggregated_random_number() -> (random_number: felt):
    end
end

@storage_var
func user_commit(user: felt) -> (commit: felt, commit_block: felt):
end

@storage_var
func aggregated_secret() -> (value: felt):
end

@storage_var
func nonce() -> (value: felt):
end

@external
func commit(user: felt, hash: felt):
    let current_block = get_block_number()
    user_commit.write(user, hash, current_block)
    return ()

@external
func reveal(user: felt, secret: felt):
    let (commit_hash, commit_block) = user_commit.read(user)

    assert hash_secret(secret) = commit_hash, "Invalid secret"

    let current_block = get_block_number()
    assert current_block - commit_block > MIN_BLOCK_DELAY, "Too early to reveal"

    let current_aggregated_secret = aggregated_secret.read()
    let new_aggregated_secret = current_aggregated_secret + secret
    aggregated_secret.write(new_aggregated_secret)
    return ()

@external
func generate_aggregated_random_number() -> (random_number: felt):
    let current_nonce = nonce.read()
    let current_aggregated_secret = aggregated_secret.read()

    let block_number = get_block_number()
    let block_timestamp = get_block_timestamp()
    
    let combined = block_number + block_timestamp + current_aggregated_secret + current_nonce
    let random_number = bitwise_and(combined, (2**250) - 1)

    nonce.write(current_nonce + 1)
    aggregated_secret.write(0)  # Reset the aggregated secret after generating the number

    return (random_number,)
end

func hash_secret(secret: felt) -> (hash: felt):
    # Implement hashing logic using Pedersen hash
    return (hash,)
end

const MIN_BLOCK_DELAY = 10  # Define a minimum number of blocks delay for the reveal
