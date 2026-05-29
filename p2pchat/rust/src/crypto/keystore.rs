use std::sync::RwLock;
use once_cell::sync::Lazy;
use libp2p::identity::Keypair as Libp2pKeypair;
use x25519_dalek::StaticSecret;
use ed25519_dalek::SigningKey;
use crate::crypto::identity::IdentityKeys;

static ACTIVE_KEYS: Lazy<RwLock<Option<IdentityKeys>>> = Lazy::new(|| RwLock::new(None));

pub fn set_identity_keys(keys: IdentityKeys) {
    let mut lock = ACTIVE_KEYS.write().unwrap();
    *lock = Some(keys);
}

pub fn clear_identity_keys() {
    let mut lock = ACTIVE_KEYS.write().unwrap();
    *lock = None;
}

pub fn get_identity_keys() -> Option<IdentityKeys> {
    let lock = ACTIVE_KEYS.read().unwrap();
    lock.clone()
}

pub fn get_libp2p_keypair() -> anyhow::Result<Libp2pKeypair> {
    let lock = ACTIVE_KEYS.read().unwrap();
    let keys = lock.as_ref().ok_or_else(|| anyhow::anyhow!("Identity keys not set in Keystore"))?;
    let libp2p_keypair = Libp2pKeypair::ed25519_from_bytes(keys.seed.clone())?;
    Ok(libp2p_keypair)
}

pub fn get_signing_key() -> anyhow::Result<SigningKey> {
    let lock = ACTIVE_KEYS.read().unwrap();
    let keys = lock.as_ref().ok_or_else(|| anyhow::anyhow!("Identity keys not set in Keystore"))?;
    let seed_array: [u8; 32] = keys.seed.clone().try_into()
        .map_err(|_| anyhow::anyhow!("Invalid seed length"))?;
    Ok(SigningKey::from_bytes(&seed_array))
}

pub fn get_box_secret() -> anyhow::Result<StaticSecret> {
    let lock = ACTIVE_KEYS.read().unwrap();
    let keys = lock.as_ref().ok_or_else(|| anyhow::anyhow!("Identity keys not set in Keystore"))?;
    let seed_array: [u8; 32] = keys.seed.clone().try_into()
        .map_err(|_| anyhow::anyhow!("Invalid seed length"))?;

    use sha2::{Sha256, Digest};
    let mut hasher = Sha256::new();
    hasher.update(&seed_array);
    hasher.update(b"x25519-derivation");
    let derived_bytes: [u8; 32] = hasher.finalize().into();
    Ok(StaticSecret::from(derived_bytes))
}
