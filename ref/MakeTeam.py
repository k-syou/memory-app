import random
import sys
from typing import List, Dict, Set, Tuple
from collections import defaultdict

try:
    from colorama import init, Fore, Back, Style
    init(autoreset=True)
    COLORAMA_AVAILABLE = True
except ImportError:
    COLORAMA_AVAILABLE = False
    # ANSI 색상 코드 (Windows 10+ 지원)
    class Fore:
        RED = '\033[91m'
        GREEN = '\033[92m'
        YELLOW = '\033[93m'
        BLUE = '\033[94m'
        MAGENTA = '\033[95m'
        CYAN = '\033[96m'
        WHITE = '\033[97m'
        RESET = '\033[0m'
    
    class Style:
        BRIGHT = '\033[1m'
        RESET_ALL = '\033[0m'


class TeamMaker:
    def __init__(self):
        self.names: List[str] = []
        self.num_teams: int = 2
        self.must_together: List[Tuple[str, str]] = []  # 반드시 함께해야 하는 쌍
        self.must_separate: List[Tuple[str, str]] = []  # 반드시 분리해야 하는 쌍
        self.team_names: List[str] = []  # 팀 이름들
        self.team_leaders: List[str] = []  # 팀장 리스트 (팀당 한 명씩)
    
    def add_names(self, names: List[str]):
        """이름 리스트 추가"""
        self.names = [name.strip() for name in names if name.strip()]
    
    def set_num_teams(self, num: int):
        """팀 개수 설정"""
        self.num_teams = max(2, num)
    
    def set_team_names(self, names: List[str]):
        """팀 이름 설정"""
        self.team_names = names[:self.num_teams]
        # 부족한 경우 자동 생성
        while len(self.team_names) < self.num_teams:
            self.team_names.append(f"팀 {len(self.team_names) + 1}")
    
    def add_must_together(self, name1: str, name2: str):
        """반드시 함께해야 하는 사람 추가"""
        if name1 in self.names and name2 in self.names:
            self.must_together.append((name1, name2))
    
    def add_must_separate(self, name1: str, name2: str):
        """반드시 분리해야 하는 사람 추가"""
        if name1 in self.names and name2 in self.names:
            self.must_separate.append((name1, name2))
    
    def set_team_leaders(self, names: List[str]):
        """팀장 설정 (팀당 한 명씩)"""
        self.team_leaders = []
        for name in names:
            name = name.strip()
            if name in self.names and name not in self.team_leaders:
                self.team_leaders.append(name)
    
    def add_team_leader(self, name: str):
        """팀장 추가"""
        name = name.strip()
        if name in self.names and name not in self.team_leaders:
            self.team_leaders.append(name)
    
    def validate_constraints(self, teams: List[List[str]]) -> Tuple[bool, List[str]]:
        """제약 조건 검증"""
        errors = []
        
        # 팀장이 각 팀에 한 명씩 있는지 확인
        if self.team_leaders:
            if len(self.team_leaders) > len(teams):
                errors.append(f"❌ 팀장 수({len(self.team_leaders)})가 팀 개수({len(teams)})보다 많습니다!")
            else:
                # 각 팀장이 서로 다른 팀에 있는지 확인
                leader_teams = {}
                for idx, team in enumerate(teams):
                    for leader in self.team_leaders:
                        if leader in team:
                            if leader in leader_teams:
                                errors.append(f"❌ 팀장 {leader}이(가) 여러 팀에 배치되었습니다!")
                            else:
                                leader_teams[leader] = idx
                
                # 모든 팀장이 배치되었는지 확인
                for leader in self.team_leaders:
                    if leader not in leader_teams:
                        errors.append(f"❌ 팀장 {leader}이(가) 배치되지 않았습니다!")
        
        # 반드시 함께해야 하는 사람들 확인
        for name1, name2 in self.must_together:
            team1_idx = None
            team2_idx = None
            for idx, team in enumerate(teams):
                if name1 in team:
                    team1_idx = idx
                if name2 in team:
                    team2_idx = idx
            if team1_idx != team2_idx:
                errors.append(f"❌ {name1}과(와) {name2}는 반드시 같은 팀이어야 합니다!")
        
        # 반드시 분리해야 하는 사람들 확인
        for name1, name2 in self.must_separate:
            for team in teams:
                if name1 in team and name2 in team:
                    errors.append(f"❌ {name1}과(와) {name2}는 같은 팀에 있을 수 없습니다!")
        
        return len(errors) == 0, errors
    
    def generate_teams(self, max_attempts: int = 1000) -> List[List[str]]:
        """팀 생성 (제약 조건 고려)"""
        if len(self.names) < self.num_teams:
            raise ValueError(f"인원 수({len(self.names)})가 팀 개수({self.num_teams})보다 적습니다!")
        
        # 팀장 수가 팀 개수보다 많으면 오류
        if len(self.team_leaders) > self.num_teams:
            raise ValueError(f"팀장 수({len(self.team_leaders)})가 팀 개수({self.num_teams})보다 많습니다!")
        
        for attempt in range(max_attempts):
            # 이름 리스트를 섞기
            shuffled = self.names.copy()
            random.shuffle(shuffled)
            
            # 팀 개수만큼 나누기
            teams = [[] for _ in range(self.num_teams)]
            
            # 팀장을 먼저 각 팀에 배치
            team_indices = list(range(self.num_teams))
            random.shuffle(team_indices)
            
            for i, leader in enumerate(self.team_leaders):
                if leader in shuffled:
                    teams[team_indices[i]].append(leader)
                    shuffled.remove(leader)
            
            # 나머지 인원을 랜덤으로 배치
            for i, name in enumerate(shuffled):
                teams[i % self.num_teams].append(name)
            
            # 제약 조건 검증
            is_valid, errors = self.validate_constraints(teams)
            if is_valid:
                return teams
        
        # 최대 시도 횟수 초과 시 경고와 함께 반환
        print(f"{Fore.YELLOW}⚠️  제약 조건을 완벽히 만족하는 팀을 생성하지 못했습니다. 최선의 결과를 반환합니다.{Fore.RESET}")
        return teams
    
    def print_teams(self, teams: List[List[str]], is_print_constraints: bool = False):
        """팀을 예쁘게 출력"""
        print("\n" + "="*80)
        print(f"{Fore.CYAN}{Style.BRIGHT}{'🎯 팀 구성 결과 🎯':^80}{Style.RESET_ALL}")
        print("="*80 + "\n")
        
        # 팀 이름이 설정되지 않았으면 자동 생성
        if not self.team_names:
            self.set_team_names([])
        
        colors = [Fore.RED, Fore.GREEN, Fore.YELLOW, Fore.BLUE, Fore.MAGENTA, Fore.CYAN]
        
        for idx, team in enumerate(teams):
            team_color = colors[idx % len(colors)]
            team_name = self.team_names[idx] if idx < len(self.team_names) else f"팀 {idx + 1}"
            
            print(f"{team_color}{Style.BRIGHT}{'─'*80}{Style.RESET_ALL}")
            print(f"{team_color}{Style.BRIGHT}  {team_name:^76}  {Style.RESET_ALL}")
            print(f"{team_color}{Style.BRIGHT}{'─'*80}{Style.RESET_ALL}")
            
            for i, member in enumerate(team, 1):
                # 팀장 표시
                leader_mark = ""
                if member in self.team_leaders:
                    leader_mark = f"{Fore.YELLOW} 👑 팀장{Style.RESET_ALL}"
                print(f"{team_color}    {i:2d}. {member:<70}{leader_mark}{Style.RESET_ALL}")
            
            print(f"{team_color}    총 인원: {len(team)}명{Style.RESET_ALL}\n")
        
        print("="*80 + "\n")
        
        # 제약 조건 정보 출력
        if is_print_constraints and (self.must_together or self.must_separate):
            print(f"{Fore.CYAN}{Style.BRIGHT}📋 제약 조건 정보{Style.RESET_ALL}")
            print(f"{Fore.CYAN}{'─'*80}{Fore.RESET}\n")
            
            if self.must_together:
                print(f"{Fore.GREEN}  ✅ 반드시 함께해야 하는 사람들:{Fore.RESET}")
                for name1, name2 in self.must_together:
                    print(f"      • {name1} ↔ {name2}")
                print()
            
            if self.must_separate:
                print(f"{Fore.RED}  ❌ 반드시 분리해야 하는 사람들:{Fore.RESET}")
                for name1, name2 in self.must_separate:
                    print(f"      • {name1} ✗ {name2}")
                print()
        
        print("="*80 + "\n")


def get_input(prompt: str, default: str = "") -> str:
    """사용자 입력 받기"""
    if default:
        user_input = input(f"{Fore.CYAN}{prompt} [{default}]: {Fore.RESET}").strip()
        return user_input if user_input else default
    return input(f"{Fore.CYAN}{prompt}: {Fore.RESET}").strip()


def main():
    print(f"\n{Fore.CYAN}{Style.BRIGHT}{'='*80}")
    print(f"{'🎲 랜덤 팀 생성 프로그램 🎲':^80}")
    print(f"{'='*80}{Style.RESET_ALL}\n")
    
    maker = TeamMaker()
    
    # 1. 이름 입력
    print(f"{Fore.YELLOW}1단계: 참가자 이름 입력{Fore.RESET}")
    print(f"{Fore.WHITE}   (쉼표 또는 공백으로 구분하여 입력하세요){Fore.RESET}\n")
    
    # names_input = get_input("참가자 이름")
    names_input = get_input("참가자 이름", "별,규,근,나,솜,민,샤,코,훈,혁,누,도,징,권,재")
    if "," in names_input:
        names = [n.strip() for n in names_input.split(",")]
    else:
        names = names_input.split()
    
    maker.add_names(names)
    
    if not maker.names:
        print(f"{Fore.RED}❌ 이름이 입력되지 않았습니다!{Fore.RESET}")
        return
    
    print(f"\n{Fore.GREEN}✓ 총 {len(maker.names)}명이 등록되었습니다: {', '.join(maker.names)}{Fore.RESET}\n")
    
    # 2. 팀 개수 설정
    print(f"{Fore.YELLOW}2단계: 팀 개수 설정{Fore.RESET}\n")
    num_teams_input = get_input("팀 개수", str(len(maker.names) // 2))
    try:
        maker.set_num_teams(int(num_teams_input))
    except ValueError:
        maker.set_num_teams(len(maker.names) // 2)
    
    # 3. 팀 이름 설정 (선택사항)
    print(f"\n{Fore.YELLOW}3단계: 팀 이름 설정 (선택사항){Fore.RESET}")
    print(f"{Fore.WHITE}   (엔터를 누르면 자동으로 '팀 1', '팀 2'... 로 설정됩니다){Fore.RESET}\n")
    team_names_input = get_input("팀 이름 (쉼표로 구분)")
    if team_names_input:
        team_names = [n.strip() for n in team_names_input.split(",")]
        maker.set_team_names(team_names)
    else:
        maker.set_team_names([])
    
    # 4. 팀장 설정 (선택사항)
    print(f"\n{Fore.YELLOW}4단계: 팀장 설정 (선택사항){Fore.RESET}")
    print(f"{Fore.WHITE}   (팀당 한 명씩 팀장을 설정할 수 있습니다. 쉼표로 구분하여 입력하세요){Fore.RESET}")
    print(f"{Fore.WHITE}   (팀장은 각각 다른 팀에 배치되며, 속한 팀에서 팀장으로 표시됩니다){Fore.RESET}\n")
    leader_input = get_input("팀장 이름 (쉼표로 구분)")
    if leader_input:
        if "," in leader_input:
            leader_names = [n.strip() for n in leader_input.split(",")]
        else:
            leader_names = [leader_input.strip()]
        
        valid_leaders = []
        invalid_leaders = []
        for name in leader_names:
            if name in maker.names:
                valid_leaders.append(name)
            else:
                invalid_leaders.append(name)
        
        if valid_leaders:
            if len(valid_leaders) > maker.num_teams:
                print(f"{Fore.RED}❌ 팀장 수({len(valid_leaders)})가 팀 개수({maker.num_teams})보다 많습니다. 처음 {maker.num_teams}명만 사용됩니다.{Fore.RESET}")
                valid_leaders = valid_leaders[:maker.num_teams]
            
            maker.set_team_leaders(valid_leaders)
            print(f"{Fore.GREEN}✓ {len(valid_leaders)}명의 팀장이 설정되었습니다: {', '.join(valid_leaders)}{Fore.RESET}\n")
        
        if invalid_leaders:
            print(f"{Fore.RED}❌ 다음 이름은 참가자 목록에 없습니다: {', '.join(invalid_leaders)}{Fore.RESET}\n")
    
    # 5. 반드시 함께해야 하는 사람 설정
    print(f"\n{Fore.YELLOW}5단계: 반드시 함께해야 하는 사람 설정 (선택사항){Fore.RESET}")
    print(f"{Fore.WHITE}   (예: '김철수,이영희' 또는 '김철수 이영희' 형식으로 입력){Fore.RESET}")
    print(f"{Fore.WHITE}   (완료하려면 엔터를 누르세요){Fore.RESET}\n")
    
    while True:
        together_input = get_input("함께해야 하는 사람 (이름1,이름2)", "나,혁")
        if together_input == "" or together_input == "n":
            break
        
        if "," in together_input:
            parts = [n.strip() for n in together_input.split(",")]
        else:
            parts = together_input.split()
        
        if len(parts) >= 2:
            maker.add_must_together(parts[0], parts[1])
            print(f"{Fore.GREEN}✓ {parts[0]}과(와) {parts[1]}는 같은 팀에 배치됩니다{Fore.RESET}\n")
        else:
            print(f"{Fore.RED}❌ 두 명의 이름을 입력해주세요{Fore.RESET}\n")
    
    # 6. 반드시 분리해야 하는 사람 설정
    print(f"\n{Fore.YELLOW}6단계: 반드시 분리해야 하는 사람 설정 (선택사항){Fore.RESET}")
    print(f"{Fore.WHITE}   (예: '김철수,이영희' 또는 '김철수 이영희' 형식으로 입력){Fore.RESET}")
    print(f"{Fore.WHITE}   (완료하려면 엔터를 누르세요){Fore.RESET}\n")
    
    while True:
        separate_input = get_input("분리해야 하는 사람 (이름1,이름2)", "근,나")
        if separate_input == "" or separate_input == "n":
            break
        
        if "," in separate_input:
            parts = [n.strip() for n in separate_input.split(",")]
        else:
            parts = separate_input.split()
        
        if len(parts) >= 2:
            maker.add_must_separate(parts[0], parts[1])
            print(f"{Fore.RED}✓ {parts[0]}과(와) {parts[1]}는 다른 팀에 배치됩니다{Fore.RESET}\n")
        else:
            print(f"{Fore.RED}❌ 두 명의 이름을 입력해주세요{Fore.RESET}\n")
    
    # 7. 팀 생성 및 출력
    print(f"\n{Fore.CYAN}{Style.BRIGHT}{'='*80}")
    print(f"{'🎲 팀 생성 중... 🎲':^80}")
    print(f"{'='*80}{Style.RESET_ALL}\n")
    
    try:
        teams = maker.generate_teams()
        maker.print_teams(teams)
        
        # 다시 생성 옵션
        while True:
            retry = get_input("\n다시 생성하시겠습니까? (y/n)", "n").lower()
            if retry == 'y' or retry == 'yes':
                teams = maker.generate_teams()
                maker.print_teams(teams)
            else:
                break
        
        print(f"\n{Fore.GREEN}{Style.BRIGHT}프로그램을 종료합니다. 감사합니다! 👋{Style.RESET_ALL}\n")
        
    except ValueError as e:
        print(f"{Fore.RED}❌ 오류: {e}{Fore.RESET}\n")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n\n{Fore.YELLOW}프로그램이 중단되었습니다.{Fore.RESET}\n")
        sys.exit(0)

