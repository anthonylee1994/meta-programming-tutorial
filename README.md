# Meta-programming

Meta-programming is the ability to write code that writes or modifies other code at runtime (or at compile time). In languages like Ruby, you can dynamically **create methods, classes, and modify existing objects while the program is running**.

---

### 🔍 Key Concepts

| Term                              | Meaning                                                                                          |
| --------------------------------- | ------------------------------------------------------------------------------------------------ |
| **Meta-program**                  | A program that treats **other programs as data**—it can read, analyze, or generate code.         |
| **Compile-time meta-programming** | Code generation or transformation **before the program runs** (e.g., macros, templates).         |
| **Run-time meta-programming**     | Code that **modifies itself or other code while executing** (e.g., reflection, dynamic proxies). |

---

### 🛠️ Examples by Language

| Language       | Meta-programming Feature | Example                                                                       |
| -------------- | ------------------------ | ----------------------------------------------------------------------------- |
| **C++**        | Templates                | `std::vector<int>` generates type-specific code at compile time.              |
| **Python**     | Decorators               | `@property` rewrites a method into a getter dynamically.                      |
| **Ruby**       | `method_missing`         | Intercepts undefined method calls to generate behavior on the fly.            |
| **Rust**       | Macros (`macro_rules!`)  | Generates code at compile time (e.g., `println!`).                            |
| **JavaScript** | Proxies                  | Intercepts object operations (e.g., `get`, `set`) to add custom logic.        |
| **Lisp**       | Code as data             | Programs are lists that can be manipulated by other programs (homoiconicity). |

---

### 🎯 Why Use It?

- **DRY (Don’t Repeat Yourself)**: Eliminate boilerplate (e.g., auto-generate getters/setters).
- **Performance**: Compile-time code generation can optimize away abstractions (e.g., C++ templates).
- **Flexibility**: Create domain-specific languages (DSLs) or frameworks (e.g., Rails’ ActiveRecord).
- **Debugging Tools**: Inject logging or profiling code automatically.

---

### ⚠️ Downsides

- **Complexity**: Harder to read/debug (e.g., C++ template errors).
- **Overuse**: Can make code opaque or fragile (e.g., monkey-patching in Ruby).
- **Performance Trade-offs**: Run-time meta-programming may add overhead.

---

### 🧠 Analogy

Think of meta-programming as a **3D printer for code**: instead of hand-crafting every part, you write a blueprint (meta-code) that **manufactures** the final code.
