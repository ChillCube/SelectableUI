# SelectableUI API Reference
Generated: 2026-05-20

an addon that manages selectable UI elements in godot

## Class: SelectableUI
**Inherits:** [SmoothUI](git@github.com:ChillCube/SmoothUI/blob/main/DOCUMENTATION.md)

UI element with selection, visual feedback, and controller/keyboard navigation support

### ⚙️ Inspector Variables (Exported)
| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| **is_selected** | `bool` | `false` | Whether this element is currently highlighted/selected. |
| **base_scale** | `float` | `0.0` | Base scale when not selected. Leave at 0 to use the node's scale at startup. |
| **selected_scale_change** | `float` | `1.1` | Scale multiplier relative to base scale when selected (1 = no change, 2 = double) |
| **selected_color** | `Color` | `Color(1.2, 1.2, 1.2, 1.0)` | Color tint applied when this element is selected |
| **lerp_time** | `float` | `0.15` | Duration in seconds for selection scale and color transitions |

### 🔔 Signals
| Signal | Arguments | Description |
| :--- | :--- | :--- |
| **selected** | - |  Emitted when this element becomes selected |
| **deselected** | - |  Emitted when this element loses selection |
| **pressed** | - |  Emitted when the accept action is pressed on this element |
| **released** | - |  Emitted when the accept action is released on this element |

---

