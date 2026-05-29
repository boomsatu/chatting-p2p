use base64::{Engine as _, engine::general_purpose::STANDARD};
use crate::crypto::{identity, keystore, dm_crypto};

#[derive(serde::Serialize, serde::Deserialize, Clone, Debug)]
pub struct IdentityInfo {
    pub seed: Vec<u8>,
    pub peer_id: String,
    pub signing_pubkey: String, // base64
    pub box_pubkey: String,     // base64
}

pub fn generate_identity() -> Result<IdentityInfo, String> {
    let keys = identity::generate_random_identity().map_err(|e| e.to_string())?;
    
    Ok(IdentityInfo {
        seed: keys.seed,
        peer_id: keys.peer_id,
        signing_pubkey: STANDARD.encode(&keys.signing_pubkey),
        box_pubkey: STANDARD.encode(&keys.box_pubkey),
    })
}

pub fn set_active_identity(seed: Vec<u8>) -> Result<String, String> {
    let seed_array: [u8; 32] = seed.try_into().map_err(|_| "Seed must be exactly 32 bytes".to_string())?;
    let keys = identity::generate_identity_from_seed(&seed_array).map_err(|e| e.to_string())?;
    let peer_id = keys.peer_id.clone();
    keystore::set_identity_keys(keys);
    Ok(peer_id)
}

pub fn clear_active_identity() {
    keystore::clear_identity_keys();
}

pub fn encrypt_dm_message(plaintext: String, recipient_pub_base64: String) -> Result<crate::models::message::DMPayload, String> {
    let recipient_pub_bytes = STANDARD.decode(&recipient_pub_base64).map_err(|e| e.to_string())?;
    let recipient_pub: [u8; 32] = recipient_pub_bytes.try_into().map_err(|_| "Recipient public key must be 32 bytes".to_string())?;
    
    let box_secret = keystore::get_box_secret().map_err(|e| e.to_string())?;
    let sender_secret: [u8; 32] = box_secret.to_bytes();
    
    let (ciphertext, nonce) = dm_crypto::encrypt_dm(plaintext.as_bytes(), &recipient_pub, &sender_secret).map_err(|e| e.to_string())?;
    
    let sender_pub = x25519_dalek::PublicKey::from(&box_secret).to_bytes();
    
    Ok(crate::models::message::DMPayload {
        nonce: STANDARD.encode(&nonce),
        ciphertext: STANDARD.encode(&ciphertext),
        sender_pub_key: STANDARD.encode(&sender_pub),
    })
}

pub fn decrypt_dm_message(payload: crate::models::message::DMPayload) -> Result<String, String> {
    let nonce_bytes = STANDARD.decode(&payload.nonce).map_err(|e| e.to_string())?;
    let nonce: [u8; 24] = nonce_bytes.try_into().map_err(|_| "Nonce must be 24 bytes".to_string())?;
    
    let ciphertext = STANDARD.decode(&payload.ciphertext).map_err(|e| e.to_string())?;
    
    let sender_pub_bytes = STANDARD.decode(&payload.sender_pub_key).map_err(|e| e.to_string())?;
    let sender_pub: [u8; 32] = sender_pub_bytes.try_into().map_err(|_| "Sender public key must be 32 bytes".to_string())?;
    
    let box_secret = keystore::get_box_secret().map_err(|e| e.to_string())?;
    let recipient_secret: [u8; 32] = box_secret.to_bytes();
    
    let decrypted_bytes = dm_crypto::decrypt_dm(&ciphertext, &nonce, &sender_pub, &recipient_secret).map_err(|e| e.to_string())?;
    
    String::from_utf8(decrypted_bytes).map_err(|e| e.to_string())
}
