use dryoc::classic::crypto_secretbox::{crypto_secretbox_easy, crypto_secretbox_open_easy};

pub fn encrypt_group(
    plaintext: &[u8],
    key: &[u8; 32],
) -> anyhow::Result<(Vec<u8>, [u8; 24])> {
    use rand::RngCore;
    let mut nonce = [0u8; 24];
    rand::rngs::OsRng.fill_bytes(&mut nonce);

    let mut ciphertext = vec![0u8; plaintext.len() + 16]; // MAC tag is 16 bytes
    crypto_secretbox_easy(
        &mut ciphertext,
        plaintext,
        &nonce,
        key,
    ).map_err(|e| anyhow::anyhow!("Group encryption failed: {:?}", e))?;

    Ok((ciphertext, nonce))
}

pub fn decrypt_group(
    ciphertext: &[u8],
    nonce: &[u8; 24],
    key: &[u8; 32],
) -> anyhow::Result<Vec<u8>> {
    if ciphertext.len() < 16 {
        return Err(anyhow::anyhow!("Ciphertext too short"));
    }
    let mut plaintext = vec![0u8; ciphertext.len() - 16];
    crypto_secretbox_open_easy(
        &mut plaintext,
        ciphertext,
        nonce,
        key,
    ).map_err(|e| anyhow::anyhow!("Group decryption failed: {:?}", e))?;

    Ok(plaintext)
}

pub fn generate_group_key() -> [u8; 32] {
    use rand::RngCore;
    let mut key = [0u8; 32];
    rand::rngs::OsRng.fill_bytes(&mut key);
    key
}
