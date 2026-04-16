// IPFS module using Helia - modern IPFS implementation
// No external daemon required

import { createHelia } from 'helia';
import { unixfs } from '@helia/unixfs';

class IPFSBlueprintStorage {
    constructor() {
        this.helia = null;
        this.fs = null;
        this.init();
    }

    async init() {
        try {
            this.helia = await createHelia();
            this.fs = unixfs(this.helia);
            console.log('Helia IPFS node initialized');
        } catch (error) {
            console.error('Failed to initialize Helia IPFS node:', error);
        }
    }

    /**
     * Store a blueprint document in IPFS with metadata
     */
    async storeBlueprint(blueprint) {
        try {
            const content = JSON.stringify(blueprint, null, 2);
            const bytes = new TextEncoder().encode(content);
            const cid = await this.fs.addBytes(bytes);

            console.log(`Stored blueprint: CID: ${cid.toString()}`);
            return cid.toString();
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
            for await (const chunk of this.fs.cat(cid)) {
                chunks.push(chunk);
            }

            const content = new TextDecoder().decode(Buffer.concat(chunks));
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

export default IPFSBlueprintStorage;