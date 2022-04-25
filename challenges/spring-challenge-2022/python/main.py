import sys
import math

# Auto-generated code below aims at helping you parse
# the standard input according to the problem statement.

# base_x: The corner of the map representing your base
base_x, base_y = [int(i) for i in input().split()]
heroes_per_player = int(input())  # Always 3

def debug(msg):
    print(msg, file=sys.stderr, flush=True)

class Entity():
    def __init__(self, id, entity_type, x, y):
        self.id = id
        self.entity_type = entity_type
        self.x = x
        self.y = y
    # Create based on class name:
    def factory(self):
        if self.type == 0: return Monster(self)
        if (self.type == 1 or self.type == 2): return Hero(self) 
        assert 0, "Bad shape creation: " + type
    factory = staticmethod(factory)

class Hero(Entity):
    def __init__(self, id, entity_type, x, y):
        super().__init__(id, entity_type, x, y)

class Monster(Entity):
    def __init__(self, id, entity_type, x, y, health, vx, vy, near_base, threat_for):
        self.health = health
        self.vx = vx
        self.vy = vy
        self.near_base = near_base
        self.threatFor = threat_for
        super().__init__(id, entity_type, x, y)

    
    def wait(self):
        pass

    def move(self, x, y):
        pass
    
# game loop
while True:
    monsters = []
    myHeroes = []
    ennemyHeroes = []
    for i in range(2):
        # health: Each player's base health
        # mana: Ignore in the first league; Spend ten mana to cast a spell
        health, mana = [int(j) for j in input().split()]
    entity_count = int(input())  # Amount of heros and monsters you can see
    for i in range(entity_count):
        # _id: Unique identifier
        # _type: 0=monster, 1=your hero, 2=opponent hero
        # x: Position of this entity
        # shield_life: Ignore for this league; Count down until shield spell fades
        # is_controlled: Ignore for this league; Equals 1 when this entity is under a control spell
        # health: Remaining health of this monster
        # vx: Trajectory of this monster
        # near_base: 0=monster with no target yet, 1=monster targeting a base
        # threat_for: Given this monster's trajectory, is it a threat to 1=your base, 2=your opponent's base, 0=neither
        _id, _type, x, y, shield_life, is_controlled, health, vx, vy, near_base, threat_for = [int(j) for j in input().split()]
        
        # PARSING ENTITY
        # If Monster
        if _type == 0:
            monsters.append(Monster(id=_id, entity_type=_type, x=x, y=y, health=health, vx=vx, vy=vy, near_base=near_base, threat_for=threat_for))
        # If my Hero
        elif _type == 1:
            pass
           # myHeroes.append(Hero(id=_id, entity_type=_type, x=x, y=y,))
        # If ennemy Hero
        elif _type == 2:
            pass
        else:
            assert False


    for i in range(heroes_per_player):

        # Write an action using print
        if monsters:
            monster = monsters.pop()
            print(f'MOVE {monster.x} {monster.y}')
        else:
            print('WAIT')
            
                    
