import {useTheme} from "../contexts/ThemeContext";

function ThemeToggleButton() {
    const {theme, toggleTheme} = useTheme();
    console.log("Current theme in button:", theme === 'light');

    return (
        <button onClick={toggleTheme}>
            Switch to {theme === 'light' ? 'Dark' : 'Light'} Theme
        </button>
    );
}

export default ThemeToggleButton;