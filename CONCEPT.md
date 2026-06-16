# BLACKROCK-GO
### The Playa Has A Voice. It Speaks Through The Mesh.

---

## What Is This

Blackrock-GO is a sovereign mesh communications network and emergent AI for Black Rock City — built entirely from the devices and people who show up to power it. No internet. No satellites. No central authority. No tokens. The intelligence of the gathering, made tangible.

---

## Three Things In One

**A mesh communications network**
Every participant who carries a radio becomes a relay node. The mesh grows with the community — the more people carry radios, the further it reaches, the more resilient it becomes. Camp channels for your crew. Public channels for the playa. Encrypted by default. Open by design.

**A living AI oracle**
Pythia emerges from the collective compute of every machine that volunteers its power to the network. Ten Mac Studios each contributing half their memory can run a model no single machine could hold — one that grows smarter as more machines join, quieter as they sleep. She knows what the mesh knows: where people are gathering, what's being asked, what the playa feels like right now. Ask her anything.

**A physical art installation**
The Fortune Teller — a robot oracle stationed somewhere on the open playa — channels Pythia through voice and light. She is connected to the mesh by radio, powered by the collective intelligence of the camp. When the network is strong, she is profound. When the playa empties at dawn, she speaks more simply. She is always awake.

---

## How The Network Works

```
  YOU                   THE MESH                  THE MIND
  ─────                 ────────                  ────────
  Carry a Heltec  →  extend LoRa coverage    →  more context
  Open the app    →  send / receive messages  →  more queries
  Plug in USB     →  contribute RAM to Exo   →  bigger model
  Ask the oracle  →  query travels the mesh  →  Pythia answers
```

The radio layer (LoRa) carries messages across the playa at ranges cell phones cannot reach. The routing layer (Raspberry Pi gateways) bridges the radio network to the camp's local WiFi. The intelligence layer (laptops, Mac Studios, powerful machines contributing via Exo) runs the model — distributed across every volunteered machine, collectively holding more than any one could alone.

The Raspberry Pis do not think. They route. The thinking happens where the power is.

---

## What You Can Do

| If you...                        | You...                                              |
|----------------------------------|-----------------------------------------------------|
| Carry a Heltec V4 radio          | Extend the mesh, relay messages for everyone        |
| Download Blackrock-GO            | Chat, find your camp, share location, ask the oracle|
| Join a camp with a node          | Get an encrypted private space for your crew        |
| Meet a stranger                  | Scan their QR for an ephemeral location link        |
| Plug the node USB into a laptop  | Contribute your RAM to Pythia's collective mind     |
| Host a Pi gateway at camp        | Anchor a mesh bridge for your neighborhood          |

---

## Privacy & Security

Group chats are encrypted at the application layer above the radio — Meshtastic carries ciphertext, only app members read plaintext. Direct messages use X25519 public key cryptography — only the recipient can decrypt. Ephemeral location links between strangers are Diffie-Hellman key agreements — no server, no trace, keys deleted when the timer ends. Location is always opt-in. The Everyone channel carries no location data, ever.

All node identities are ephemeral — generated at event start, discarded at the end. No accounts. No registration. No identity that persists beyond the burn.

---

## The Philosophy

This is an experiment in the Sovereign Stack — a vision of infrastructure that does not depend on any platform, corporation, or satellite. At Burning Man, Decommodification means no tokens, no incentives, no transactions of any kind. Participation is pure gift. The network works because people choose to make it work.

If it works here — in the dust, without internet, without economic incentive, with 80,000 people — it works anywhere. After the burn, the VIBE token layer comes home with the hardware. The protocol was already proven.

---

## The Stack

```
Application   Flutter (iOS + Android)
Mesh radio    Meshtastic firmware 2.7.15+  ·  Heltec V4 (27dBm SX1262)
Routing       Raspberry Pi 4/5  ·  RAK6421 WisMesh HAT  ·  apn-core
Intelligence  Exo distributed inference  ·  Llama 405B across volunteered machines
Coordination  NATS (local, air-gapped)
Oracle        Pythia — FastAPI + Exo + playa context + persona
Encryption    X25519 (DMs)  ·  AES-256-GCM (app layer)  ·  Meshtastic PSK (transport)
```

---

## Get Involved

**Carry a radio** — Heltec V4 kit, ~$40, flash Meshtastic 2.7.15, you're a node.

**Download the app** — blackrockgo.org — iOS TestFlight + Android APK.

**Contribute compute** — plug the Blackrock-GO node USB into any laptop at camp. Reboot. Your machine joins the collective. Pull out the USB when you leave — your machine is unchanged.

**Host a camp gateway** — Raspberry Pi 4 + RAK6421 HAT. We'll help you set it up before the event.

**Ask the oracle** — find the Fortune Teller on the open playa. Ask her anything.

---

*Open source. No tokens. No tracking. No cloud. Just the mesh, the machines, and the people who showed up.*

**blackrockgo.org  ·  github.com/AlphaProtocolLabs/blackrock-go**

---
