### About
Here is the technical checklist for client onboarding to start BUEROKRATT deployment

### Essentials for Bürokratt adoption

#### Contracts

- [ ] TARA contract
- [ ] Riigipilv contract

#### Technical steps

- [ ] Planning the Riigipilv project recurces. Both production and test projects require 4 VM's, 8 in total. Check requirements [here](../main/Requirements.md)
- [ ] Planning DNS. Floating IP is tagged during the deployment of VM designated as `VM-bykstack`. That same IP must be registered at your DNS provider. URLS bound with ths IP, must be modified according to your DNS domain
- [ ] Writing the URLS. Check the example [here](../main/Requirements.md#url-requirements)
- [ ] Grant access by public keys

#### Infrastructure

TO DO

#### Deployment

TO DO

### Testing

- [ ] GUI
- [ ] Backoffice

### Handover

- [ ] Remove public keys created for temporary devops, etc
- [ ] Regenerate TARA password if necessary
