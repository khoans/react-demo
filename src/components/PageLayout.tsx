import {Outlet} from "@tanstack/react-router";
import ThemeToggleButton from "@/components/ThemeToggleButton.tsx";

function PageLayout() {
  return (
    <div className="container-layout">
      <header className="header">Header</header>
      <main className="main-content">Main Content</main>
      <footer className="footer">Footer</footer>
        <ThemeToggleButton />
        <Outlet />
    </div>
  );
}

export default PageLayout;