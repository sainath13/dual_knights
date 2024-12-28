import questionary

class LevelEditor:
    def __init__(self, rows, cols):
        self.rows = rows
        self.cols = cols
        self.grid = [[None for _ in range(cols)] for _ in range(rows)]
        self.characters = {
            'Block': 'Collisionblocks',
            'AntiPlayerCheckpoint': 'Checkpoints',
            'PlayerCheckpoint': 'Checkpoints',
            'Player': 'Spawnpoints',
            'AntiPlayer': 'Spawnpoints',
            'Barrel': 'Spawnpoints',
            'Tree': 'Spawnpoints',
        }

    def display_grid(self):
        print("\nCurrent Grid:")
        for row in self.grid:
            print([cell if cell else '.' for cell in row])
        print()

    def select_character(self):
        choices = list(self.characters.keys()) + ["Skip"]
        choice = questionary.select(
            "Select a character:", choices=choices
        ).ask()
        return choice if choice != "Skip" else None

    def edit_grid(self):
        for row in range(self.rows):
            for col in range(self.cols):
                print(f"\nEditing cell ({row}, {col}):")
                self.grid[row][col] = self.select_character()
                self.display_grid()

    def save_to_file(self, filename):
        data = {
            'Collisionblocks': [],
            'Checkpoints': [],
            'Spawnpoints': []
        }

        for row in range(self.rows):
            for col in range(self.cols):
                character = self.grid[row][col]
                if character:
                    layer = self.characters[character]
                    if layer == 'Collisionblocks':
                        data[layer].append((row, col))
                    else:
                        data[layer].append((row, col, character))

        with open(filename, 'w') as f:
            for layer, items in data.items():
                f.write(f"{layer}:\n")
                for item in items:
                    f.write(f"  {item}\n")
        print(f"Level data saved to {filename}")


if __name__ == "__main__":
    editor = LevelEditor(9, 6)
    editor.edit_grid()
    editor.save_to_file("level_data.txt")

