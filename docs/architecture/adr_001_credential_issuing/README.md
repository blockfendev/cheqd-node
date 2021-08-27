## Option 1
According to Aries protocol we can use payment decorators `~payment_request` and `~payment_receipt`. 

### Step 1: Credential Offer
A message sent by the Issuer to the potential Holder, describing the credential they intend to offer and possibly the price they expect to be paid.
[Aries Credential Offer](https://github.com/hyperledger/aries-rfcs/blob/main/features/0036-issue-credential/README.md#offer-credential)
```{
    "@type": "https://didcomm.org/issue-credential/1.0/offer-credential",
    "@id": "<uuid-of-offer-message>",
    "comment": "some comment",
    "credential_preview": <json-ld object>,
    "offers~attach": [
                        {
                            "@id": "libindy-cred-offer-0",
                            "mime-type": "application/json",
                            "data": {
                                        "base64": "<bytes for base64>"
                                    }
                        }
                    ]
    "~payment_request": { ... }
}
```
And use a payment decorator to add information about an issuing price and address for sending payment transaction.
[Aries payment_request decorator](https://github.com/hyperledger/aries-rfcs/blob/main/features/0075-payment-decorators/README.md#payment_request)
```
   "~payment_request": {
        "methodData": [
          {
            "supportedMethods": "cheqd",
            "data": {
              "payeeId": "cosmos1fknpjldck6n3v2wu86arpz8xjnfc60f99ylcjd"
            },
          }
        ],
        "details": {
          "id": "0a2bc4a6-1f45-4ff0-a046-703c71ab845d",
          "displayItems": [
            {
              "label": "commercial driver's license",
              "amount": { "currency": "cheq", "value": "10" },
            }
          ],
          "total": {
            "label": "Total due",
            "amount": { "currency": "cheq", "value": "10" }
          }
        }
      }
```
- `details.id` field contains an invoice number that unambiguously identifies a credential for which payment is requested. When paying, this value should be placed in `memo` field for Cheqd payment transaction.
- `payeeId` field contains a Cheqd account address in the cosmos format.

### Step 2: Payment transaction 
This operation has 5 steps:
* *Step 2.1.* Build a request for transferring coins. Example: `cheqd_ledger::bank::build_msg_send(account_id, second_account, amount_for_transfer, denom)`. 
* *Step 2.2.* Built a transaction with the request from the previous step. Example: `cheqd_ledger::auth::build_tx(pool_alias, pub_key, &msg, account_number, account_sequence, max_gas, max_coin_amount, denom, timeout_height, memo)`. 
* *Step 2.3.* Sign a transaction from the previous step. `cheqd_keys::sign(wallet_handle, key_alias, &tx)`. 
* *Step 2.4.* Broadcast a signed transaction from the previous step. `cheqd_pool::broadcast_tx_commit(pool_alias, &signed)`. 
* *Step 2.5.* Parse response after broadcasting from the previous step. `cheqd_ledger::bank::parse_msg_send_resp(&resp)`. 
[Read more about Cheqd payment transaction](https://gitlab.com/evernym/verity/vdr-tools/-/tree/cheqd/docs/design/014-bank-transactions)

### Step 3: Credential Request
This is a message sent by the potential Holder to the Issuer, to request the issuance of a credential.
```
{
    "@type": "https://didcomm.org/issue_credential/1.0/request_credential",
    "@id": "94af9be9-5248-4a65-ad14-3e7a6c3489b6",
    "~thread": { "thid": "5bc1989d-f5c1-4eb1-89dd-21fd47093d96" },
    "cred_def_id": "KTwaKJkvyjKKf55uc6U8ZB:3:CL:59:tag1",
    "~payment_receipt": {
      "request_id": "0a2bc4a6-1f45-4ff0-a046-703c71ab845d",
      "selected_method": "cheqd",
      "transaction_id": "0x5674bfea99c480e110ea61c3e52783506e2c467f108b3068d642712aca4ea479",
      "payeeId": "0xD15239C7e7dDd46575DaD9134a1bae81068AB2A4",
      "amount": { "currency": "cheq", "value": "10.0" }
    }
}
```


### Step 4: Credential issuing
Issuer receives Credential Request + `payment_receipt` with payment `transaction_id`. It allows Issuer 
- get the payment transaction by hash from Cheqd Ledger (`get_tx_by_hash` method)
- check `memo` field from Credential Offer in the transaction.

## Option 2

### Step 1: Credential Offer
The same with option 1 but instead of `~payment_request` use `~payment_info` 
```
payment_info ->
                    {
                    "amount": string, - price for issuing
                    "denom" : string - denomination for paying
                    "from": string, - source payment account (Holder)
                    "to": string, - target payment account (Issuer)
                    "memo": string, - metadata
                    "balance": string, - empty
                    "transaction_hash" - empty
                    }
```
### Step 2: Payment transaction 
The same
### Step 3: Credential Request
The same with option 1 but instead of `~payment_receipt` use `~payment_info`
```
payment_info ->
                    {
                    "amount": string, - amount of tokens was How much money do you need
                    "denom" : string - denomination for paying
                    "balance": string, - new balance
                    "from": string, - source payment account
                    "to": string, - target payment account
                    "memo": string, - passed metadata
                    "transaction_hash": string - hash of transaction_hash
                    }
```