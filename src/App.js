import logo from "./logo.svg";
import "./App.css";

function App() {
  const clientName = process.env.REACT_APP_CLIENT_NAME;
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          App Client: <code>{clientName}</code>.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
