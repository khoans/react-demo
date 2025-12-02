export class BrowserStorageUtil implements KeyValueStorage {
    private storage: Storage;

    constructor(storage: Storage = localStorage) {
        if (window === undefined || !storage) {
            throw new Error("Storage is not available in this environment.");
        }
        this.storage = storage;
    }

    getItem(key: string): string | null {
        return this.storage.getItem(key);
    }

    getAllKeys(): string[] {
        const keys: string[] = [];
        for (let i = 0; i < this.storage.length; i++) {
            const key = this.storage.key(i);
            if (key) {
                keys.push(key);
            }
        }
        return keys;
    }

    getAllKeysWithPrefix(prefix: string): string[] {
        const keys: string[] = [];
        for (let i = 0; i < this.storage.length; i++) {
            const key = this.storage.key(i);
            if (key && key.startsWith(prefix)) {
                keys.push(key);
            }
        }
        return keys;
    }

    getAllItems(): Record<string, string> {
        const items: Record<string, string> = {};
        for (let i = 0; i < this.storage.length; i++) {
            const key = this.storage.key(i);
            if (key) {
                const value = this.storage.getItem(key);
                if (value !== null) {
                    items[key] = value;
                }
            }
        }
        return items;
    }

    removeItem(key: string): void {
        this.storage.removeItem(key);
    }

    removeItems(keys: string[]): void {
        keys.forEach((key) => this.storage.removeItem(key));
    }

    setItem(key: string, value: string): void {
        this.storage.setItem(key, value);
    }

    setItems(items: Record<string, string>): void {
        for (const [key, value] of Object.entries(items)) {
            this.storage.setItem(key, value);
        }
    }

    clearAll(): void {
        this.storage.clear();
    }
}