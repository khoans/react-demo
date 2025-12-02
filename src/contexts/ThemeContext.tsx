/* eslint-disable react-refresh/only-export-components */
import {createContext, useContext, useEffect, useState} from 'react';
import type {ReactNode} from 'react';

type Theme = 'light' | 'dark';

interface ThemeContextType {
    theme: Theme;
    toggleTheme: () => void;
    setTheme: (theme: Theme) => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);


const checkSystemPreference = (): Theme => {
    if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        return 'dark';
    }
    return 'light';
}

export function ThemeProvider({children}: { children: ReactNode }) {
    const [theme, setThemeState] = useState<Theme>(() => {
        // Check localStorage first
        const savedTheme = localStorage.getItem('theme') as Theme | null;
        if (savedTheme) return savedTheme;

        // Then check system preference
        const systemTheme = checkSystemPreference();

        return systemTheme || 'light';
    });

    useEffect(() => {
        const root = document.documentElement;

        if (theme === 'dark') {
            root.classList.add('dark');
            console.log('Dark mode enabled - classList:', root.classList.toString());
        } else {
            root.classList.remove('dark');
            console.log('Light mode enabled - classList:', root.classList.toString());
        }

        // Save to localStorage
        localStorage.setItem('theme', theme);
    }, [theme]);

    const toggleTheme = () => {
        setThemeState(prev => prev === 'light' ? 'dark' : 'light');
    };

    const setTheme = (newTheme: Theme) => {
        setThemeState(newTheme);
    };

    return (
        <ThemeContext.Provider value={{theme, toggleTheme, setTheme}}>
            {children}
        </ThemeContext.Provider>
    );
}

export function useTheme() {
    const context = useContext(ThemeContext);
    if (context === undefined) {
        throw new Error('useTheme must be used within a ThemeProvider');
    }
    return context;
}

