import {useTheme} from "../contexts/ThemeContext";

function ThemeToggleButton() {
    const {theme, toggleTheme} = useTheme();

    const displayTheme = theme === 'light' ? 'Light' : 'Dark';

    return (
        <button onClick={toggleTheme}>
            Switch to {displayTheme} Theme
        </button>
    );
}

export default ThemeToggleButton;