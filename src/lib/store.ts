// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import { createContext, useContext } from 'react'

export interface Subject {
  id: string
  naam: string
  icon: string
  volgorde: number
  topics: Topic[]
}

export interface Topic {
  id: string
  subjectId: string
  titel: string
  content: string
  slug: string
}

export interface Bookmark {
  topicId: string
  timestamp: number
}

export interface Note {
  id: string
  topicId?: string
  title: string
  content: string
  updatedAt: number
}

export interface StudySession {
  id: string
  subjectId: string
  startedAt: number
  duration: number
}

export interface AppState {
  subjects: Subject[]
  bookmarks: Bookmark[]
  notes: Note[]
  sessions: StudySession[]
  syncStatus: 'idle' | 'syncing' | 'done' | 'error'
  lastSyncSha: string | null
  currentView: string
}

export const initialState: AppState = {
  subjects: [],
  bookmarks: [],
  notes: [],
  sessions: [],
  syncStatus: 'idle',
  lastSyncSha: null,
  currentView: 'huis',
}

export type AppAction =
  | { type: 'SET_SUBJECTS'; payload: Subject[] }
  | { type: 'SET_SYNC_STATUS'; payload: AppState['syncStatus'] }
  | { type: 'SET_LAST_SHA'; payload: string }
  | { type: 'ADD_BOOKMARK'; payload: Bookmark }
  | { type: 'REMOVE_BOOKMARK'; payload: string }
  | { type: 'ADD_NOTE'; payload: Note }
  | { type: 'UPDATE_NOTE'; payload: Note }
  | { type: 'DELETE_NOTE'; payload: string }
  | { type: 'ADD_SESSION'; payload: StudySession }
  | { type: 'SET_VIEW'; payload: string }

export function appReducer(state: AppState, action: AppAction): AppState {
  switch (action.type) {
    case 'SET_SUBJECTS':
      return { ...state, subjects: action.payload }
    case 'SET_SYNC_STATUS':
      return { ...state, syncStatus: action.payload }
    case 'SET_LAST_SHA':
      return { ...state, lastSyncSha: action.payload }
    case 'ADD_BOOKMARK':
      return { ...state, bookmarks: [...state.bookmarks, action.payload] }
    case 'REMOVE_BOOKMARK':
      return { ...state, bookmarks: state.bookmarks.filter(b => b.topicId !== action.payload) }
    case 'ADD_NOTE':
      return { ...state, notes: [...state.notes, action.payload] }
    case 'UPDATE_NOTE':
      return { ...state, notes: state.notes.map(n => n.id === action.payload.id ? action.payload : n) }
    case 'DELETE_NOTE':
      return { ...state, notes: state.notes.filter(n => n.id !== action.payload) }
    case 'ADD_SESSION':
      return { ...state, sessions: [...state.sessions, action.payload] }
    case 'SET_VIEW':
      return { ...state, currentView: action.payload }
    default:
      return state
  }
}

interface AppContextType {
  state: AppState
  dispatch: React.Dispatch<AppAction>
}

export const AppContext = createContext<AppContextType>({
  state: initialState,
  dispatch: () => {},
})

export function useApp() {
  return useContext(AppContext)
}
