interface KeyValueStorage {
    getItem(key: string): string | null;
    getAllKeys(): string[];
    getAllItems(): Record<string, string>;
    setItem(key: string, value: string): void;
    setItems(items: Record<string, string>): void;
    removeItem(key: string): void;
    removeItems(keys: string[]): void;
    clearAll(): void;
}
