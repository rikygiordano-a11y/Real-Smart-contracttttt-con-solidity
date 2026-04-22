# Progetto Smart Contract con Solidity

# Panoramica del Progetto

Questo progetto consiste nello sviluppo di uno smart contract in Solidity per la gestione di una piattaforma di prestiti peer-to-peer su blockchain.

L’obiettivo è permettere agli utenti di:

- creare richieste di prestito
- finanziare un prestito
- restituire il prestito con interessi
- applicare penali in caso di ritardo
- visualizzare tutti i dati del prestito
- gestire lo stato del prestito in modo sicuro e trasparente

Il progetto è stato sviluppato utilizzando Remix IDE e pubblicato sulla testnet Sepolia.

---

# Struttura del Progetto

Il progetto è composto da 2 file principali:

- LoanManager.sol
- LoanMath.sol

## LoanManager.sol

Contratto principale che gestisce tutta la logica dei prestiti.

## LoanMath.sol

Libreria Solidity utilizzata dal contratto principale per eseguire i calcoli di:

- interessi
- penali per ritardo

La libreria viene richiamata automaticamente da LoanManager.sol, quindi non necessita di deploy separato.

---

# Tecnologie Utilizzate

- Solidity ^0.8.20
- Remix IDE
- MetaMask
- WalletConnect
- Sepolia Testnet
- Blockchain Ethereum

---

# Funzionalità Implementate

## Creazione Prestito

Un utente può creare un’offerta di prestito specificando:

- importo
- tasso di interesse
- durata del prestito

Il prestatore deposita i fondi direttamente nello smart contract.

---

## Accettazione Prestito

Un altro utente può accettare il prestito tramite ID.

Il contratto:

- assegna borrower e lender
- trasferisce i fondi al richiedente
- imposta il prestito come ACTIVE
- registra data di inizio e scadenza

---

## Rimborso Prestito

Il borrower può restituire il prestito inviando il valore corretto.

Il contratto calcola automaticamente:

- capitale iniziale
- interessi
- eventuali penali

Dopo il pagamento:

- i fondi tornano al lender
- lo stato diventa PAID

---

## Stati del Prestito

Ogni prestito può assumere i seguenti stati:

- PENDING
- ACTIVE
- PAID
- OVERDUE
- CANCELLED

---

## Visualizzazione Dati Prestito

È possibile consultare un prestito tramite ID con la funzione getLoan(id).

La funzione restituisce:

- lender
- borrower
- amount
- interestRate
- duration
- startDate
- endDate
- status

---

# Librerie e Calcoli

## LoanMath.sol

La libreria contiene due funzioni principali.

## calculateInterest()

Calcola l’interesse in base a:

- importo del prestito
- tasso di interesse
- durata del prestito

Formula utilizzata:

interesse = importo × tasso × giorni / (100 × 365)

## calculatePenalty()

Calcola la penale in caso di ritardo nel rimborso considerando:

- importo del prestito
- data di scadenza
- data del pagamento

---

# Sicurezza Implementata

Sono stati inseriti controlli di sicurezza tramite require() per verificare:

- importo valido
- durata valida
- prestito esistente
- stato corretto del prestito
- solo borrower può rimborsare
- pagamento corretto
- nessun doppio utilizzo del prestito
- nessun accesso non autorizzato

---

# Test Eseguiti

Tutti i test sono stati eseguiti con successo prima su Remix VM e successivamente su Sepolia.

---

## Test 1 - Creazione Prestito

Creato prestito con:

- amount: 1 ETH
- interestRate: 10
- duration: 86400 secondi

Risultato: Prestito creato correttamente.

---

## Test 2 - Accettazione Prestito

Eseguita funzione takeLoan(1)

Risultato:

- borrower assegnato
- fondi trasferiti
- stato ACTIVE

---

## Test 3 - Rimborso Prestito

Eseguita funzione repayLoan(1)

Risultato:

- pagamento completato
- fondi inviati al lender
- stato PAID

---

## Test 4 - Lettura Dati Prestito

Eseguita funzione getLoan(1)

Risultato:

- dati visualizzati correttamente
- lender corretto
- borrower corretto
- importo corretto
- date corrette
- stato corretto

---

## Test 5 - Deploy Blockchain

Contratto pubblicato con successo sulla rete Sepolia.

Risultato: Deploy completato.

---

# Contract Deployment

## Network

Sepolia Testnet

## Contract Address

0x5777A8675C4053EF9826c090EB9F1BdA3f9F58e4

---

# GitHub Repository

https://github.com/rikygiordano-a11y/Real-Smart-contracttttt-con-solidity.git

---

# Conclusione

Il progetto dimostra l’utilizzo pratico degli smart contract per la gestione di prestiti decentralizzati.

Sono state implementate con successo tutte le funzionalità richieste:

- creazione prestito
- accettazione prestito
- rimborso prestito
- interessi
- penali
- gestione stati
- sicurezza
- test completi
- deploy su Sepolia

