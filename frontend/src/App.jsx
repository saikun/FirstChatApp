import { useState, useEffect, useRef } from 'react'
import axios from 'axios'
import { motion, AnimatePresence } from 'framer-motion'
import { Send, User, MessageCircle } from 'lucide-react'
import './App.css'

// Hardcoded ALB URL as requested
const API_BASE_URL = 'http://chatappalb-1932012177.ap-northeast-1.elb.amazonaws.com/api'
console.log('API Base URL:', API_BASE_URL)

function App() {
  const [messages, setMessages] = useState([])
  const [inputText, setInputText] = useState('')
  const [username, setUsername] = useState('')
  const [isLoggedIn, setIsLoggedIn] = useState(false)
  const messagesEndRef = useRef(null)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" })
  }

  useEffect(() => {
    if (isLoggedIn) {
      const fetchMessages = async () => {
        try {
          const response = await axios.get(`${API_BASE_URL}/messages`)
          setMessages(response.data)
        } catch (error) {
          console.error('Error fetching messages:', error)
        }
      }

      fetchMessages()
      const interval = setInterval(fetchMessages, 2000)
      return () => clearInterval(interval)
    }
  }, [isLoggedIn])

  useEffect(() => {
    scrollToBottom()
  }, [messages])

  const handleSendMessage = async (e) => {
    e.preventDefault()
    if (!inputText.trim()) return

    try {
      await axios.post(`${API_BASE_URL}/messages`, {
        user: username,
        text: inputText
      })
      setInputText('')
    } catch (error) {
      console.error('Error sending message:', error)
    }
  }

  if (!isLoggedIn) {
    return (
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="login-container"
      >
        <div className="glass-card login-card">
          <h1>Chat App</h1>
          <p>Welcome! Please enter your name to join.</p>
          <form onSubmit={(e) => { e.preventDefault(); if (username.trim()) setIsLoggedIn(true) }}>
            <div className="input-group">
              <User size={20} />
              <input
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                autoFocus
              />
            </div>
            <button type="submit" className="primary-button">Join Chat</button>
          </form>
        </div>
      </motion.div>
    )
  }

  return (
    <div className="app-container">
      <header className="glass-header">
        <div className="header-content">
          <MessageCircle size={24} />
          <h2>Lounge</h2>
          <div className="user-badge">
            <User size={14} />
            <span>{username}</span>
          </div>
        </div>
      </header>

      <div className="chat-window glass-card">
        <div className="messages-list">
          <AnimatePresence initial={false}>
            {messages.map((msg) => (
              <motion.div
                key={msg.id}
                initial={{ opacity: 0, scale: 0.9, y: 10 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                className={`message-item ${msg.user === username ? 'own-message' : ''}`}
              >
                <div className="message-bubble">
                  <div className="message-user">{msg.user}</div>
                  <div className="message-text">{msg.text}</div>
                  <div className="message-time">
                    {new Date(msg.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  </div>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
          <div ref={messagesEndRef} />
        </div>

        <form className="message-input-area" onSubmit={handleSendMessage}>
          <input
            type="text"
            placeholder="Type a message..."
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
          />
          <button type="submit" className="send-button">
            <Send size={20} />
          </button>
        </form>
      </div>
    </div>
  )
}

export default App
