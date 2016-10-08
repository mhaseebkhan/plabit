# Plabit

Plabit is a simple web app that gives you access to all your bank accounts

# Setup

Ruby Version: 2.2.1

bundle install

## Starting the Server

rake server

## OAuth
Currently when hit on sandbox mode, the user is authenticated through Plaid through to the respective bank. The credentials for the sandbox mode to work appear below once clicked. Once authenticated, the transactions for that specific user will appear at /transactions.

## Transactions
If /transactions will be accessed directly, the Plaid test user's transactions will follow and the companies info will be viewable through View Info hyperlinks

## Tests

rake test:all

