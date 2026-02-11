import from uuid { uuid4 }
cl import "./styles.css";

import from byllm.lib { Model }

glob llm = Model(model_name="gemini/gemini-2.5-flash");

enum Category { WORK, PERSONAL, SHOPPING, HEALTH, OTHER }
def categorize(title: str) -> Category by llm();

# NEW: priority enum + AI priority
enum Priority { HIGH, MEDIUM, LOW }
def prioritize(title: str) -> Priority by llm();

# A node becomes a persistent data container in the graph when attached to a root node
node Todo {
    has id: str,
        title: str,
        done: bool = False,
        category: str = "other",
        priority: str = "medium";
}

"""Add a todo with AI categorization."""
def:pub add_todo(title: str) -> dict {
    category = str(categorize(title)).split(".")[-1].lower();
    priority = str(prioritize(title)).split(".")[-1].lower();
    
    todo = root ++> Todo(
        id=str(uuid4()),
        title=title,
        category=category,
        priority=priority
    );

    return {
        "id": todo[0].id,
        "title": todo[0].title,
        "done": todo[0].done,
        "category": todo[0].category,
        "priority": todo[0].priority
    };
}

"""Get all todos."""
def:pub get_todos -> list {
    return [
        {
            "id": t.id,
            "title": t.title,
            "done": t.done,
            "category": t.category,
            "priority": t.priority
        }
        for t in [root-->](?:Todo)
    ];
}

"""Toggle a todo's done status."""
def:pub toggle_todo(id: str) -> dict {
    for todo in [root-->](?:Todo) {
        if todo.id == id {
            todo.done = not todo.done;
            return {
                "id": todo.id,
                "title": todo.title,
                "done": todo.done,
                "category": todo.category,
                "priority": todo.priority
            };
        }
    }
    return {};
}

"""Delete a todo."""
def:pub delete_todo(id: str) -> dict {
    for todo in [root-->](?:Todo) {
        if todo.id == id {
            del todo;
            return {"deleted": id};
        }
    }
    return {};
}

cl def:pub app -> any {
    has items: list = [],
        text: str = "",
        sort_by_priority: bool = True;

    async can with entry {
        items = await get_todos();
    }

    async def add -> None {
        if text.trim() {
            todo = await add_todo(text.trim());
            items = items.concat([todo]);
            text = "";
        }
    }

    async def toggle(id: str) -> None {
        await toggle_todo(id);
        items = items.map(
            lambda t: any -> any {
                return {
                    "id": t.id,
                    "title": t.title,
                    "done": not t.done,
                    "category": t.category,
                    "priority": t.priority
                }
                if t.id == id else t;
            }
        );
    }

    async def remove(id: str) -> None {
        await delete_todo(id);
        items = items.filter(lambda t: any -> bool { return t.id != id; });
    }

    # NEW: simple priority order
    pr_rank = lambda p: str -> int {
        return 0 if p == "high" else (1 if p == "medium" else 2);
    };

    # NEW: optionally sorted view
    view_items = items;
    if sort_by_priority {
        view_items = items.slice().sort(
            lambda a: any, b: any -> int {
                return pr_rank(a.priority) - pr_rank(b.priority);
            }
        );
    }

    remaining = items.filter(lambda t: any -> bool { return not t.done; }).length;

    return
        <div class="container">
            <h1>Todo App</h1>
            <div class="input-row">
                <input
                    class="input"
                    value={text}
                    onChange={lambda e: any -> None { text = e.target.value; }}
                    onKeyPress={lambda e: any -> None {
                        if e.key == "Enter" { add(); }
                    }}
                    placeholder="What needs to be done?"
                />
                <button class="btn-add" onClick={add}>Add</button>
            </div>

            <div class="input-row">
                <button class="btn-add" onClick={lambda -> None {
                    sort_by_priority = not sort_by_priority;
                }}>
                    {"Sort: Priority" if sort_by_priority else "Sort: Added order"}
                </button>
            </div>

            {[
                <div key={t.id} class="todo-item">
                    <input
                        type="checkbox"
                        checked={t.done}
                        onChange={lambda -> None { toggle(t.id); }}
                    />
                    <span class={"todo-title " + ("todo-done" if t.done else "")}>
                        {t.title}
                    </span>

                    <span class="category">{t.priority}</span>
                    
                    <span class="category">{t.category}</span>

                    <button
                        class="btn-delete"
                        onClick={lambda -> None { remove(t.id); }}
                    >
                        X
                    </button>
                </div> for t in items
            ]}
            <div class="count">{remaining} items remaining</div>
        </div>;
}
