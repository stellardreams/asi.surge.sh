/**
 * IPFS Storage Service using Helia
 * 
 * Provides decentralized storage for blueprints and documents
 * using Helia (modern IPFS implementation) without external daemons.
 * 
 * @example
 * ```javascript
 * const storage = new IPFSStorage();
 * await storage.init();
 * const cid = await storage.storeBlueprint({ name: 'My Design' });
 * const data = await storage.retrieveBlueprint(cid);
 * ```
 */
export class IPFSStorage {
  /**
   * Creates a new IPFSStorage instance
   * 
   * @param {Object} [options] - Configuration options
   * @param {boolean} [options.autoInit=true] - Auto-initialize on construction
   */
  constructor(options = {}) {
    this.helia = null;
    this.fs = null;
    this.initialized = false;
    this.autoInit = options.autoInit ?? true;
    
    if (this.autoInit) {
      // Defer initialization to avoid constructor side effects
      setTimeout(() => this.init().catch(console.error), 0);
    }
  }

  /**
   * Initializes the Helia IPFS node
   * 
   * @returns {Promise<boolean>} True if initialization succeeded
   * @throws {Error} If initialization fails
   * 
   * @example
   * ```javascript
   * const storage = new IPFSStorage({ autoInit: false });
   * await storage.init();
   * ```
   */
  async init() {
    try {
      const { createHelia } = await import('helia');
      const { unixfs } = await import('@helia/unixfs');
      
      this.helia = await createHelia();
      this.fs = unixfs(this.helia);
      this.initialized = true;
      
      console.log('✅ Helia IPFS node initialized');
      return true;
    } catch (error) {
      console.error('❌ Failed to initialize Helia IPFS node:', error.message);
      this.initialized = false;
      throw error;
    }
  }

  /**
   * Stores a blueprint document in IPFS
   * 
   * @param {Object} blueprint - Blueprint document to store
   * @param {string} blueprint.type - Blueprint type (e.g., '3-stage-AMU')
   * @param {string} blueprint.name - Blueprint name
   * @param {Array} blueprint.components - Blueprint components
   * @returns {Promise<string>} CID of stored content
   * @throws {Error} If storage fails or not initialized
   * 
   * @example
   * ```javascript
   * const cid = await storage.storeBlueprint({
   *   type: '3-stage-AMU',
   *   name: 'My Design',
   *   components: []
   * });
   * console.log('Stored at CID:', cid);
   * ```
   */
  async storeBlueprint(blueprint) {
    this.ensureInitialized();
    
    try {
      const content = JSON.stringify(blueprint, null, 2);
      const bytes = new TextEncoder().encode(content);
      const cid = await this.fs.addBytes(bytes);
      
      console.log(`📁 Stored blueprint: ${cid.toString()}`);
      return cid.toString();
    } catch (error) {
      console.error('❌ Failed to store blueprint:', error.message);
      throw error;
    }
  }

  /**
   * Retrieves a blueprint from IPFS by CID
   * 
   * @param {string} cid - Content identifier
   * @returns {Promise<Object>} Retrieved blueprint document
   * @throws {Error} If retrieval fails or not initialized
   * 
   * @example
   * ```javascript
   * const blueprint = await storage.retrieveBlueprint('Qm...');
   * console.log(blueprint.name);
   * ```
   */
  async retrieveBlueprint(cid) {
    this.ensureInitialized();
    
    try {
      const chunks = [];
      for await (const chunk of this.fs.cat(cid)) {
        chunks.push(chunk);
      }
      
      const content = Buffer.concat(chunks).toString();
      return JSON.parse(content);
    } catch (error) {
      console.error('❌ Failed to retrieve blueprint:', error.message);
      throw error;
    }
  }

  /**
   * Stores any JSON-serializable data in IPFS
   * 
   * @param {Object} data - Data to store
   * @returns {Promise<string>} CID of stored content
   * @throws {Error} If storage fails
   * 
   * @example
   * ```javascript
   * const cid = await storage.store({ key: 'value' });
   * ```
   */
  async store(data) {
    this.ensureInitialized();
    
    try {
      const content = JSON.stringify(data, null, 2);
      const bytes = new TextEncoder().encode(content);
      const cid = await this.fs.addBytes(bytes);
      
      return cid.toString();
    } catch (error) {
      console.error('❌ Failed to store data:', error.message);
      throw error;
    }
  }

  /**
   * Retrieves data from IPFS by CID
   * 
   * @param {string} cid - Content identifier
   * @returns {Promise<Object>} Retrieved data
   * @throws {Error} If retrieval fails
   * 
   * @example
   * ```javascript
   * const data = await storage.retrieve('Qm...');
   * ```
   */
  async retrieve(cid) {
    this.ensureInitialized();
    
    try {
      const chunks = [];
      for await (const chunk of this.fs.cat(cid)) {
        chunks.push(chunk);
      }
      
      const content = Buffer.concat(chunks).toString();
      return JSON.parse(content);
    } catch (error) {
      console.error('❌ Failed to retrieve data:', error.message);
      throw error;
    }
  }

  /**
   * Checks if the storage is initialized
   * 
   * @returns {boolean} True if initialized
   */
  isInitialized() {
    return this.initialized;
  }

  /**
   * Ensures storage is initialized before operations
   * 
   * @private
   * @throws {Error} If not initialized
   */
  ensureInitialized() {
    if (!this.initialized) {
      throw new Error('IPFSStorage not initialized. Call init() first.');
    }
  }

  /**
   * Closes the Helia node
   * 
   * @returns {Promise<void>}
   * 
   * @example
   * ```javascript
   * await storage.close();
   * ```
   */
  async close() {
    if (this.helia) {
      await this.helia.stop();
      this.initialized = false;
      console.log('🛑 Helia IPFS node stopped');
    }
  }
}
