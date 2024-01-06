Feature: Guilds

    A hypercube of audio-emotional moments
    Inspired by the Medieval craft guilds of Transylvania
    For chamber quintet - flute, bassoon, viola, violin, and percussion

    # Initial Marketplace

    Scenario: Mint initial 8x8x8 ultrarare CUBE
        Given there are 8 guilds
        And there are 8 styles
        And there are 8 editions
        When I mint an ultrarare CUBE on XYZ
        Then I should have one 8x8x8 ultrarare CUBE

    Scenario: Send ultrarare CUBE to meltable contract, first and only time

    # Deploy

    Scenario: Deploy meltable contract to testnet

    Scenario: Deploy meltable contract to mainnet

    # Token Metadata

    Scenario: Token metadata for 64 common moments

    Scenario: Token metadata for 8 uncommon STYLE moment strips

    Scenario: Token metadata for 8 uncommon GUILD moment strips

    Scenario: Token metadata for 1 rare MOSAIC moment

    Scenario: Token metadata for 1 ultrarare CUBE

    # Contract Metadata

    Scenario: Contract metadata and Collection page

    # Transfer

    Scenario: Transfer and Balance checks for 64 common moments

    Scenario: Transfer and Balance checks for 8 uncommon STYLE moment strips

    Scenario: Transfer and Balance checks for 8 uncommon GUILD moment strips

    Scenario: Transfer and Balance checks for 1 rare MOSAIC moment

    Scenario: Transfer and Balance checks for 1 ultrarare CUBE

    # Approvals

    Scenario: Alice approves Bob for specific token ID

    Scenario: Alice approves Bob for all token IDs

    Scenario: Alice revokes Bob's approval for specific token ID

    Scenario: Alice revokes Bob's approval for all token IDs

    # Meltable Functions

    Scenario: Melt all 8 common guilds of a single style into 1 uncommon STYLE moment strip

    Scenario: Unmelt 1 uncommon STYLE moment strip into 8 common guilds of a single style

    Scenario: Melt all 8 common styles of a single guild into 1 uncommon GUILD moment strip

    Scenario: Unmelt 1 uncommon GUILD moment strip into 8 common styles of a single guild

    Scenario: Melt all 64 common moments into 1 rare MOSAIC moment

    Scenario: Unmelt 1 rare MOSAIC moment into 64 common moments

    Scenario: Melt all 64 common moments into 1 ultrarare CUBE

    Scenario: Unmelt 1 ultrarare CUBE into 64 common moments

    # Sad Paths

    @Revert
    Scenario Outline: Insufficient balances
        Given there are <guild> guilds
        And there are <style> styles
        When I eat <eat> cucumbers
        Then I should have <left> cucumbers

        Examples:
            | start | eat | left |
            | 12    | 5   | 7    |
            | 20    | 5   | 15   |

    @Revert
    Scenario Outline: Insufficient approvals
        Given there are <guild> guilds
        And there are <style> styles
        When I eat <eat> cucumbers
        Then I should have <left> cucumbers

        Examples:
            | start | eat | left |
            | 12    | 5   | 7    |
            | 20    | 5   | 15   |
