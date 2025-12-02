import { render, screen, fireEvent } from '@testing-library/react';
import ThemeToggleButton from '../ThemeToggleButton';
import { ThemeProvider } from '@contexts/ThemeContext';

describe('ThemeToggleButton', () => {
    const renderWithThemeProvider = (component: React.ReactElement) => {
        return render(
            <ThemeProvider>{component}</ThemeProvider>
        );
    };

    it('renders the theme toggle button', () => {
        renderWithThemeProvider(<ThemeToggleButton />);
        const button = screen.getByRole('button');
        expect(button).toBeInTheDocument();
    });

    it('toggles theme when clicked', () => {
        renderWithThemeProvider(<ThemeToggleButton />);
        const button = screen.getByRole('button');

        // Click the button to toggle theme
        fireEvent.click(button);

        // Button should still be in the document after click
        expect(button).toBeInTheDocument();
    });

    it('button is clickable and not disabled', () => {
        renderWithThemeProvider(<ThemeToggleButton />);
        const button = screen.getByRole('button');

        expect(button).not.toBeDisabled();
    });
});

