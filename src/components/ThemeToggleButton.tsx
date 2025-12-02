import {useTheme} from "../contexts/ThemeContext.tsx";

function ThemeToggleButton() {
    const { theme, toggleTheme } = useTheme();

  return (
    <button onClick={toggleTheme}>
      Switch to {theme === 'light' ? 'Dark' : 'Light'} Theme
    </button>
  );
}

export default ThemeToggleButton;