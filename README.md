# Todo List with Priority Feature

A Jac client-side application with React support.

## Name and UMID

Anik Mumssen, UMID: 38540320

## New Feature Added

I added a priority system to the todo application that automatically labels each task as high, medium, or low importance. Instead of requiring the user to manually select a level, the feature uses the built-in `by llm()` capability to analyze the task title and infer urgency. The assigned value is stored with the todo item and displayed in the interface alongside the category. I also implemented optional sorting so higher-priority tasks appear first, helping users focus on what matters most. This improvement makes the app smarter, reduces friction when adding tasks, and demonstrates practical integration of AI-driven decision making within everyday workflows.

## Instructions on how to install and run the application

### 1. Create and activate a virtual environment
```bash
python3 -m venv myenv
source myenv/bin/activate
```

### 2. Install dependencies
```bash
pip install jaseci
```

### 3. Set your API key (in the same terminal session)
```bash
export GEMINI_API_KEY="your-key-here"
```

### 4. Start the Jac dev server
```bash
jac start main.jac
```

### 5. Open in your broswer
http://localhost:8000/


## How does the feature work?

The priority feature enhances the todo application by automatically determining the importance of each task and integrating that information into both storage and presentation. When a user enters a title, the system calls an AI-powered function defined with the `by llm()` capability, which classifies the task into one of three levels: high, medium, or low. This value is converted into a string and saved as part of the persistent `Todo` node, ensuring it remains associated with the item across future operations. The backend functions that create, retrieve, and update todos were extended to include this additional attribute in their returned data structures. On the client side, a lightweight ranking helper translates priority labels into numeric order, enabling dynamic sorting so more urgent tasks appear first. The relevant logic is primarily located near the enum and AI function definitions at the top of the file, the `priority` field within the node declaration, and the sorting and rendering updates inside the application component.
