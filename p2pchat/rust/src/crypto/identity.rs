use ed25519_dalek::SigningKey;
use x25519_dalek::StaticSecret;
use libp2p::identity::Keypair as Libp2pKeypair;
use libp2p::PeerId;
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct IdentityKeys {
    pub seed: Vec<u8>,
    pub peer_id: String,
    pub signing_pubkey: Vec<u8>,
    pub box_pubkey: Vec<u8>,
}

pub fn generate_identity_from_seed(seed_bytes: &[u8; 32]) -> anyhow::Result<IdentityKeys> {
    // 1. Libp2p Keypair (Network)
    let libp2p_keypair = Libp2pKeypair::ed25519_from_bytes(seed_bytes.to_vec())?;
    let peer_id = PeerId::from(libp2p_keypair.public()).to_string();

    // 2. Ed25519 Dalek Keypair (Signing)
    let signing_key = SigningKey::from_bytes(seed_bytes);
    let signing_pubkey = signing_key.verifying_key().to_bytes().to_vec();

    // 3. X25519 Dalek Keypair (Box Encryption)
    // Derive X25519 secret by hashing the seed to ensure safe isolation of keys
    use sha2::{Sha256, Digest};
    let mut hasher = Sha256::new();
    hasher.update(seed_bytes);
    hasher.update(b"x25519-derivation");
    let derived_bytes: [u8; 32] = hasher.finalize().into();
    let box_secret = StaticSecret::from(derived_bytes);
    let box_pubkey = x25519_dalek::PublicKey::from(&box_secret).to_bytes().to_vec();

    Ok(IdentityKeys {
        seed: seed_bytes.to_vec(),
        peer_id,
        signing_pubkey,
        box_pubkey,
    })
}

pub fn generate_random_identity() -> anyhow::Result<IdentityKeys> {
    use rand::RngCore;
    let mut seed = [0u8; 32];
    rand::rngs::OsRng.fill_bytes(&mut seed);
    generate_identity_from_seed(&seed)
}
