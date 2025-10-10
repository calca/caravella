# PSD2 Banking Integration Setup Guide (Local-First)

## Overview

This document provides complete instructions for implementing the GoCardless PSD2 banking integration in Caravella with a **LOCAL-FIRST architecture**. Premium users can connect their bank accounts and sync transactions, with all data **encrypted and stored locally on device only**.

## ⚠️ Important: Privacy-First Architecture

**NO BANKING DATA IS EVER STORED ON BACKEND SERVERS**

- ✅ All transactions stored encrypted locally on device
- ✅ Edge Function acts only as stateless proxy to GoCardless
- ✅ Encryption keys stored in device secure storage (Keychain/Keystore)
- ✅ Backend never persists any banking data
- ✅ Full GDPR compliance through local-only storage
- ✅ User maintains complete control of their data

See complete setup guide in the repository docs.
