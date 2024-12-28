import questionary

class LevelEditor:
    def __init__(self, rows, cols):
        self.rows = rows
        self.cols = cols
        self.grid = [[None for _ in range(cols)] for _ in range(rows)]
        self.characters = {
            'Empty': None,
            'Block': 'Collisionblocks',
            'AntiPlayerCheckpoint': 'Checkpoints',
            'PlayerCheckpoint': 'Checkpoints',
            'Player': 'Spawnpoints',
            'AntiPlayer': 'Spawnpoints',
            'Barrel': 'Spawnpoints',
            'Tree': 'Spawnpoints',
        }
        self.start_x = 256
        self.start_y = 192
        self.tile_size = 64
        self.placed_characters = set()

    def display_grid(self):
        print("\nCurrent Grid:")
        for row in self.grid:
            print([cell if cell else '.' for cell in row])
        print()

    def select_character(self):
        available_characters = [char for char in self.characters.keys() if char not in self.placed_characters]
        choice = questionary.select(
            "Select a character:", choices=available_characters
        ).ask()
        return choice if choice != "Empty" else None

    def edit_grid(self):
        for row in range(self.rows):
            for col in range(self.cols):
                print(f"\nEditing cell ({row}, {col}):")
                selected_character = self.select_character()
                if selected_character:
                    self.grid[row][col] = selected_character
                    # Add to placed_characters if it's Player, AntiPlayer, or their checkpoints
                    if selected_character in ['Player', 'AntiPlayer', 'PlayerCheckpoint', 'AntiPlayerCheckpoint']:
                        self.placed_characters.add(selected_character)
                self.display_grid()

    def save_to_file(self, filename):
        object_id = 1
        objectgroup_id = 5
        data = {layer: [] for layer in self.characters.values() if layer}

        for row in range(self.rows):
            for col in range(self.cols):
                character = self.grid[row][col]
                if character:
                    layer = self.characters[character]
                    x = self.start_x + col * self.tile_size
                    y = self.start_y + row * self.tile_size
                    data[layer].append(
                        f'<object id="{object_id}" name="{character}" type="{character}" '
                        f'x="{x}" y="{y}" width="{self.tile_size}" height="{self.tile_size}"/>'
                    )
                    object_id += 1

        with open(filename, 'w') as f:
            for layer, objects in data.items():
                f.write(f'<objectgroup id="{objectgroup_id}" name="{layer}">\n')
                for obj in objects:
                    f.write(f'  {obj}\n')
                f.write(f'</objectgroup>\n')
                objectgroup_id += 1
        print(f"Level data saved to {filename}")


if __name__ == "__main__":
    editor = LevelEditor(6, 9)
    editor.edit_grid()
    editor.save_to_file("level_data.xml")

