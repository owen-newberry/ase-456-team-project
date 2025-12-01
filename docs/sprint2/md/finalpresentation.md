---
marp: true
size: 4:3
paginate: true
---

# ASE 420 Team Project  
## Justice Gang  
### Movie App — Two-Sprint Review

---

## Team

- Owen Newberry — Team Lead 
- Austin Shelton 
- Cley Shelton 
- David-Michael Davies 

All team members used AI assistance option #2 (assisted).

---

## Team Rules & Working Agreements

- K.I.S.S. (Keep It Simple & Stupid)
- Start early, finish early — avoid last-minute rushes
- No surprises: keep status updates transparent
- Be on time to meetings and respond promptly
- Commit code to GitHub regularly and push progress
- Submit weekly progress reports on Canvas
- Respectful, accountable collaboration; ask for help early

---

## Project Vision & Goals

- Expand functionality to include TV show support and improved discovery
- Improve UI/UX consistency and allow user theme personalization
- Implement recommendation, randomization, and daily highlight features
- Finalize navigation flow for a cohesive app experience
- Maintain integrations and ensure reliability

---

## Features & Assigned Requirements (Summary)

- Cley Shelton
	- Features: TV show browsing; navigation from login to home
	- Requirements: Browse TV shows; navigate from login/signup to home
- David-Michael Davies
	- Features: Dark mode/theme switching; Random Movie button; UI polish
	- Requirements: Toggle themes; consistent UI; random movie discovery
- Austin Shelton
	- Features: Suggested Movies; Best Recent Releases; Movie of the Day; In Theaters Now
	- Requirements: Personalized suggestions; recent releases list; daily highlight; ticket links for in-theaters

---

## Sprint 1 — Objectives

- Research and prototype core features
	- API investigation for movies and TV shows
	- UI wireframes for home, detail, and login flow
- Implement baseline app structure
	- Login/signup flow skeleton
	- Basic movie list and details pages
	- Project scaffolding and repo setup
- Begin Cley’s TV show UI components and data parsing
- Start David-Michael's theme switcher prototype
- Begin Austin's suggestion logic research and wireframes

---

## Sprint 1 — Achievements

- Completed core repo scaffolding and CI for Hugo site (documentation)
- Implemented login → home navigation flow (basic routing)
- Basic movie browsing and details view implemented
- TV show data model researched and initial UI components built by Cley
- Theme switching prototype implemented (David-Michael)
- Recommendation logic prototyped and tested with sample data (Austin)

---

## Sprint 2 — Objectives

- Finalize TV show integration and navigation flows
- Polish UI/UX across pages; finalize dark mode and theme toggling
- Complete suggestion system: Suggested Movies, Best Recent, Movie of the Day
- Add Random Movie feature and In Theaters Now with ticket links
- Test end-to-end navigation and stability; prepare for deployment

---

## Sprint 2 — Achievements

- TV show browsing integrated with API; users can switch between movies and TV shows
- Full navigation path: login → home → (movies/TV) → details implemented and tested
- Dark mode/theme toggle completed and applied site-wide (consistent UI fixes)
- Random Movie button implemented and wired to data store
- Suggested Movies and Best Recent Releases sections implemented; Movie of the Day added
- 'In Theaters Now' list with external ticket links implemented and validated

---

## Metrics & Project Statistics (Sprint Totals)

- Total features completed: 19 
- Total LoC: ~2,500 (approx.)
- Team burndown rate: 100%

---

## Challenges & Mitigations

- API data inconsistencies (TV vs Movie schemas)
	- Mitigation: built normalization layer to present consistent model to UI
- Syncing design across contributors
	- Mitigation: agreed on color variables, spacing, and shared CSS tokens
- Time management
	- Mitigation: weekly progress reports, enforced mini-deadlines

---

