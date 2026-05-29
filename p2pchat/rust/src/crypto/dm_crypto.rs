use dryoc::classic::crypto_box::{crypto_box_easy, crypto_box_open_easy};

pub fn encrypt_dm(
    plaintext: &[u8],
    recipient_pub: &[u8; 32],
    sender_secret: &[u8; 32],
) -> anyhow::Result<(Vec<u8>, [u8; 24])> {
    use rand::RngCore;
    let mut nonce = [0u8; 24];
    rand::rngs::OsRng.fill_bytes(&mut nonce);

    let mut ciphertext = vec![0u8; plaintext.len() + 16]; // MAC tag is 16 bytes
    crypto_box_easy(
        &mut ciphertext,
        plaintext,
        &nonce,
        recipient_pub,
        sender_secret,
    ).map_err(|e| anyhow::anyhow!("Encryption failed: {:?}", e))?;

    Ok((ciphertext, nonce))
}

pub fn decrypt_dm(
    ciphertext: &[u8],
    nonce: &[u8; 24],
    sender_pub: &[u8; 32],
    recipient_secret: &[u8; 32],
) -> anyhow::Result<Vec<u8>> {
    if ciphertext.len() < 16 {
        return Err(anyhow::anyhow!("Ciphertext too short"));
    }
    let mut plaintext = vec![0u8; ciphertext.len() - 16];
    crypto_box_open_easy(
        &mut plaintext,
        ciphertext,
        nonce,
        sender_pub,
        recipient_secret,
    ).map_err(|e| anyhow::anyhow!("Decryption failed: {:?}", e))?;

    Ok(plaintext)
}
