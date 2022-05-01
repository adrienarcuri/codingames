import sys
import math

# Auto-generated code below aims at helping you parse
# the standard input according to the problem statement.

# Constants
BASE_VISIBILITY = 6000 + 1100
HERO_VISIBILITY = 2200

MAP_ZONE = ((0, 0),(17630, 9000))
MAP_ZONE_TO_EXPLORE = [(BASE_VISIBILITY, BASE_VISIBILITY),(BASE_VISIBILITY, 0),(0, BASE_VISIBILITY)]

#pi/2
cosPI2 = math.sqrt(2)/2
sinPI2 = cosPI2
# pi/8
cosPI8 = math.sqrt(2+math.sqrt(2))/2
sinPI8 = math.sqrt(2-math.sqrt(2))/2

MAP_ZONE_TO_EXPLORE = [(int(BASE_VISIBILITY * cosPI2), int(BASE_VISIBILITY * sinPI2)),(int(cosPI8 * BASE_VISIBILITY) ,int(sinPI8 *BASE_VISIBILITY)),(int(sinPI8 * BASE_VISIBILITY), int(cosPI8 * BASE_VISIBILITY))]


# base_x: The corner of the map representing your base
base_x, base_y = [int(i) for i in input().split()]
heroes_per_player = int(input())  # Always 3

def debug(msg):
    print(msg, file=sys.stderr, flush=True)

def distance_to_my_base(x,y):
    return math.dist([base_x,base_y],[x, y])

class Entity():
    def __init__(self, id, entity_type, x, y):
        self.id = id
        self.entity_type = entity_type
        self.x = x
        self.y = y
    
class Hero(Entity):
    def __init__(self, id, entity_type, x, y):
        super().__init__(id, entity_type, x, y)

class Monster(Entity):
    def __init__(self, id, entity_type, x, y, health, vx, vy, near_base, threat_for):
        self.health = health
        self.vx = vx
        self.vy = vy
        self.near_base = near_base
        self.threat_for = threat_for
        super().__init__(id, entity_type, x, y)
        
        self.threat = self._threat()

    
    def _threat(self):
        return 1/(1 + distance_to_my_base(self.x, self.y))
    
    def __str__(self):
        debug(f'id:{self.id},theat:{self.threat}, entity_type:{self.entity_type}, x:{x}, y:{y}')
    

class Commands():

    @staticmethod
    def _p(cmd, msg):
        print(f'{cmd} {msg}')

    @staticmethod
    def wait():
        cmd = 'WAIT'
        msg = 'Attend ! 🕗'
        Commands._p(cmd,msg)
    @staticmethod
    def move(x, y):
        cmd = f'MOVE {x} {y}'
        msg = 'Bouge ! 🏃‍♀️'
        Commands._p(cmd,msg)

    @staticmethod 
    def spell(x, y):
        cmd = f'SPELL WIND  {x} {y}'
        msg = 'Et le vent souflera 💨'
        Commands._p(cmd,msg)
    
    @staticmethod
    def shield(s):
        cmd = f'SPELL SHIELD {s}'
        msg = 'Bouclier 🛡'
        Commands._p(cmd,msg)
    
    

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
        
        # Garder uniquement les monstres qui sont une menace
        monsters = [monster for monster in monsters if monster.threat_for  == 1]
        # S'il y a des monstres menaçants
        if monsters:
            monsters.sort(key=lambda x: x.threat, reverse=True)

            monster = monsters[0]
            Commands.move(monster.x, monster.y)
        # S'il n'y a pas de monstre
        elif not monsters:
            # Explore
            Commands.move(MAP_ZONE_TO_EXPLORE[i][0], MAP_ZONE_TO_EXPLORE[i][1])

        else:
            Commands.wait()
            
                    
