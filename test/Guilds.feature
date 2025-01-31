Feature: Guilds

    An 8x8x8 hypercube of audio-emotional moments
    Inspired by the Medieval craft guilds of Transilvania
    For chamber quintet - flute, bassoon, viola, violin, percussion

    Actors:
    - GUILDS Deployer (Deploys GUILDS contract)
    - GUILDS Sales (Mints CUBE, Unmelts CUBE, Lists moments for sale, Receives GUILDS royalties)
    - Neodaoist.eth (Creates initial CUBE 1/1 on marketplace)
    - ClassicalMusicFan.eth (Buys 8x8x3 moments, Melts 2 strips and 1 sheet)

    # [x] Initial Marketplace

    Scenario: Mint initial 8x8x8 ultrarare CUBE
        Given there are 8 guilds
        And there are 8 styles
        And there are 8 editions
        When I mint an ultrarare CUBE on XYZ
        Then I should have one 8x8x8 ultrarare CUBE

    Scenario: Send ultrarare CUBE to meltable contract, first time and only time

    # [x] Deploy

    Scenario: Deploy meltable contract to testnet

    Scenario: Deploy meltable contract to mainnet

    # [x] Token Metadata (images and animations on IPFS, JSON onchain)

    Scenario: Token metadata for 64 common moments

    Scenario: Token metadata for 8 uncommon GUILD moment strips

    Scenario: Token metadata for 8 uncommon STYLE moment strips

    Scenario: Token metadata for 1 rare MOSAIC moment sheet

    Scenario: Token metadata for 1 ultrarare CUBE

    # [x] Collection Metadata

    Scenario: Collection metadata

    # [x] Meltable Functions

    Scenario: Melt all 8 common styles of a single guild into 1 uncommon GUILD moment strip

    Scenario: Unmelt 1 uncommon GUILD moment strip into 8 common styles of a single guild

    Scenario: Melt all 8 common guilds of a single style into 1 uncommon STYLE moment strip

    Scenario: Unmelt 1 uncommon STYLE moment strip into 8 common guilds of a single style

    Scenario: Melt all 64 common moments into 1 rare MOSAIC moment

    Scenario: Unmelt 1 rare MOSAIC moment into 64 common moments

    Scenario: Melt all 64 common moments into 1 ultrarare CUBE

    Scenario: Unmelt 1 ultrarare CUBE into 64 common moments

    # [x] Royalty Info

    Scenario: Royalty info for any token
