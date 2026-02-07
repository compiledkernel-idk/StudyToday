// SPDX-FileCopyrightText: 2026 compiledkernel-idk
//
// SPDX-License-Identifier: GPL-3.0-or-later

import type { Variants, Transition } from 'framer-motion'

// Spring configs
export const springs = {
  gentle: { type: 'spring' as const, stiffness: 200, damping: 20 },
  bouncy: { type: 'spring' as const, stiffness: 400, damping: 25 },
  stiff: { type: 'spring' as const, stiffness: 500, damping: 30 },
  smooth: { type: 'spring' as const, stiffness: 300, damping: 30 },
} satisfies Record<string, Transition>

// Page transition variants
export const pageVariants: Variants = {
  initial: { opacity: 0, scale: 0.98, y: 10 },
  enter: { opacity: 1, scale: 1, y: 0, transition: springs.smooth },
  exit: { opacity: 0, scale: 0.98, y: -10, transition: { duration: 0.15 } },
}

// Stagger container
export const staggerContainer: Variants = {
  initial: {},
  enter: {
    transition: {
      staggerChildren: 0.05,
      delayChildren: 0.1,
    },
  },
}

// Stagger item
export const staggerItem: Variants = {
  initial: { opacity: 0, y: 20 },
  enter: { opacity: 1, y: 0, transition: springs.gentle },
}

// Fade in
export const fadeIn: Variants = {
  initial: { opacity: 0 },
  enter: { opacity: 1, transition: { duration: 0.4 } },
  exit: { opacity: 0, transition: { duration: 0.15 } },
}

// Scale in (for modals/overlays)
export const scaleIn: Variants = {
  initial: { opacity: 0, scale: 0.95 },
  enter: { opacity: 1, scale: 1, transition: springs.bouncy },
  exit: { opacity: 0, scale: 0.95, transition: { duration: 0.15 } },
}

// Slide from left (sidebar expand)
export const slideFromLeft: Variants = {
  collapsed: { width: 72 },
  expanded: { width: 260, transition: springs.stiff },
}

// Card hover
export const cardHover = {
  rest: { y: 0, scale: 1 },
  hover: { y: -4, scale: 1.01, transition: springs.gentle },
  tap: { scale: 0.98, transition: { duration: 0.1 } },
}

// Shake (wrong answer)
export const shake: Variants = {
  shake: {
    x: [0, -6, 6, -4, 4, -2, 2, 0],
    transition: { duration: 0.4 },
  },
}

// Glow pulse
export const glowPulse: Variants = {
  pulse: {
    boxShadow: [
      '0 0 0px rgba(16, 185, 129, 0)',
      '0 0 24px rgba(16, 185, 129, 0.4)',
      '0 0 0px rgba(16, 185, 129, 0)',
    ],
    transition: { duration: 0.6 },
  },
}

// Sidebar pill indicator
export const pillIndicator: Variants = {
  initial: { opacity: 0 },
  animate: { opacity: 1, transition: springs.stiff },
}

// Flip card (flashcard)
export const flipCard = {
  front: { rotateY: 0, transition: springs.smooth },
  back: { rotateY: 180, transition: springs.smooth },
}

// Float (ambient elements)
export const floatAnimation = {
  animate: {
    y: [0, -10, 5, 0],
    rotate: [0, 1, -1, 0],
    transition: {
      duration: 6,
      repeat: Infinity,
      ease: 'easeInOut',
    },
  },
}
