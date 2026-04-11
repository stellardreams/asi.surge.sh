const IPFS = require('ipfs');
const fs = require('fs');

class IPFSBlueprintStorage {
    constructor() {
        this.node = null;
        this.init();
    }

    async init() {
        try {
            this.node = await IPFS.create({
                repo: './ipfs-repo',
                multiaddr: '/ip4/127.0.0.1/tcp/4001',
                peerstore: {
                    store: new(require('peer-store'))()
                }
            });
            console.log('IPFS node initialized');
        } catch (error) {
            console.error('Failed to initialize IPFS node:', error);
        }
    }

    /**
     * Store a blueprint document in IPFS with metadata
     */
    async storeBlueprint(blueprint) {
        try {
            const content = JSON.stringify(blueprint, null, 2);
            const result = await this.node.add(content);
            
            console.log(`Stored blueprint: ${result.path}, CID: ${result.cid.toString()}`);
            return result.cid.toString();
        } catch (error) {
            console.error('Failed to store blueprint:', error);
            throw error;
        }
    }

    /**
     * Retrieve a blueprint from IPFS by CID
     */
    async getBlueprint(cid) {
        try {
            const chunks = [];
            for await (const chunk of this.node.get(cid)) {
                chunks.push(chunk);
            }
            
            const content = Buffer.concat(chunks).toString();
            return JSON.parse(content);
        } catch (error) {
            console.error('Failed to retrieve blueprint:', error);
            throw error;
        }
    }

    /**
     * Store multiple blueprints in a batch
     */
    async storeBlueprints(blueprints) {
        const results = [];
        for (const blueprint of blueprints) {
            try {
                const cid = await this.storeBlueprint(blueprint);
                results.push({ cid, blueprint });
            } catch (error) {
                console.error('Failed to store blueprint:', blueprint.name, error);
            }
        }
        return results;
    }

    /**
     * Create a directory structure for versioned blueprints
     */
    async storeVersionedBlueprint(blueprint, version) {
        const versionedBlueprint = {
            ...blueprint,
            version: version,
            timestamp: Date.now(),
            storedAt: `blueprints/${blueprint.type}/${version}/${blueprint.name}-${version}.json`
        };
        return await this.storeBlueprint(versionedBlueprint);
    }
}

module.exports = IPFSBlueprintStorage;