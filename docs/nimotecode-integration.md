# NimoteCode integration contract

1. Download the versioned `nimotecode-linux-presets-vMAJOR.MINOR.PATCH.tar.gz`
   release asset and verify it against its adjacent `.sha256` asset from the
   approved release channel.
2. Extract the bundle, load its root `manifest.json`, select a named preset,
   and verify the preset-manifest SHA-256 from the root manifest.
3. Resolve `installScript` and `verifyScript` only as relative paths inside the
   extracted bundle. Verify each declared SHA-256, then display the name,
   description and size estimate before requesting confirmation.
4. Over the existing local SSH transport, execute install then verify in the
   current Linux environment. Persist the preset ID/version only after both
   return zero.

NimoteCode must never execute an arbitrary URL or a script whose path/hash is
not declared by the verified manifest. It displays `stable` by default; beta
requires the user's advanced opt-in. It does not transmit projects, SSH keys,
environment variables, or Android data to presets.
