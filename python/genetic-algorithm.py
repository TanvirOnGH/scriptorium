# Based on: <https://github.com/lucidrains/nim-genetic-algorithm/raw/refs/heads/main/ga.nim>
# Removed concurrency (malebolgia in ga.nim) for simplicity in Python, using sequential processing.
# ga.nim used arbitrary ASCII bytes in the genes, but this limits it to printable ASCII characters for diversity.
# Mutation in ga.nim is a small tweak (increment/decrement by 1), while this uses complete character substitution.

import random
import string

# Configuration
TARGET = "Attention is not all you need!"
POPULATION_SIZE = 50
MUTATION_RATE = 0.3
KEEP_FITTEST_FRAC = 0.35


# Gene class represents a potential solution
class Gene:
    def __init__(self, code=None):
        self.code = code if code else self._random_code(len(TARGET))
        self.cost = self.calculate_cost()

    def _random_code(self, length):
        return "".join(random.choice(string.printable[:95]) for _ in range(length))

    def calculate_cost(self):
        """Calculate cost as the sum of squared differences in ASCII values between the gene and the target."""
        return sum(
            (ord(self.code[i]) - ord(TARGET[i])) ** 2 for i in range(len(TARGET))
        )

    def mutate(self):
        """Randomly change one character in the code."""
        code_list = list(self.code)
        index = random.randint(0, len(self.code) - 1)
        new_char = random.choice(
            string.printable[:95]
        )  # Pick a random printable character for more diversity
        code_list[index] = new_char
        self.code = "".join(code_list)
        self.cost = self.calculate_cost()


# Mate two genes to create a new one
def mate(gene1, gene2):
    pivot = random.randint(1, len(gene1.code) - 2)
    new_code = gene1.code[:pivot] + gene2.code[pivot:]
    return Gene(new_code)


# Population class holds the entire population of genes
class Population:
    def __init__(self):
        self.pool = [Gene() for _ in range(POPULATION_SIZE)]
        self.generation = 0
        self.solved = False

    def evolve(self):
        """Evolve the population by performing selection, mating, and mutation."""
        if self.solved:
            return

        # Sort by fitness (lower cost is better)
        self.pool.sort(key=lambda g: g.cost)

        # Check if solution is found
        if self.pool[0].cost == 0:
            self.solved = True
            return

        # Keep only the fittest
        num_survive = int(KEEP_FITTEST_FRAC * POPULATION_SIZE)
        self.pool = self.pool[:num_survive]

        # Breed new offspring
        while len(self.pool) < POPULATION_SIZE:
            parent1, parent2 = random.sample(self.pool, 2)
            self.pool.append(mate(parent1, parent2))

        # Mutate
        for gene in self.pool:
            if random.random() < MUTATION_RATE:
                gene.mutate()

        self.generation += 1

    def display(self):
        """Display the current generation of genes with unique codes."""
        print(f"Generation: {self.generation}")
        seen = set()
        unique_genes = [
            g for g in self.pool if g.code not in seen and not seen.add(g.code)
        ]

        # Top Genes
        for gene in unique_genes[:10]:  # Display only the top 10 unique genes
            print(f"{gene.code} ({gene.cost})")
        print("=" * 40)


def main():
    population = Population()

    while not population.solved:
        population.evolve()
        population.display()


if __name__ == "__main__":
    main()
