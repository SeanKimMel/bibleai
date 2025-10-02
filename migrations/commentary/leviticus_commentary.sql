-- 레위기 전체 해석 데이터 (Leviticus Commentary)
-- 거룩함과 제사 제도에 관한 하나님의 교육서

-- 레위기 1장: 번제 규례
UPDATE bible_verses SET
    chapter_title = '번제 규례',
    chapter_summary = '하나님께서 모세를 부르시어 번제에 대한 규례를 주십니다. 소, 양, 염소, 비둘기로 드리는 번제의 방법이 자세히 설명되며, 제물은 흠 없는 것이어야 하고 안수하여 죄를 전가한 후 잡아서 각을 뜨고 제단에서 태워 여호와께 향기로운 냄새가 되게 합니다.',
    chapter_themes = '["번제 규례", "흠 없는 제물", "안수와 죄 전가", "향기로운 냄새", "속죄와 헌신"]',
    chapter_context = '레위기의 시작으로 제사 제도의 핵심인 번제를 다룹니다. 번제는 완전한 헌신과 속죄를 상징하며 그리스도의 십자가 희생을 예표합니다.',
    chapter_application = '하나님께 온전히 헌신하며, 흠 없으신 예수 그리스도를 통해 죄 사함을 받고, 삶 전체가 하나님께 향기로운 제물이 되어야 합니다.'
WHERE book_id = 'lv' AND chapter = 1 AND verse = 1;

-- 레위기 2장: 소제 규례
UPDATE bible_verses SET
    chapter_title = '소제 규례',
    chapter_summary = '고운 가루로 드리는 소제의 규례가 주어집니다. 기름을 붓고 유향을 놓아 제사장에게 가져가면 기념물을 취하여 제단에서 태우고 나머지는 제사장들이 먹습니다. 누룩과 꿀은 넣지 말고 소금은 빠뜨리지 말라고 합니다.',
    chapter_themes = '["소제 규례", "고운 가루와 기름", "유향의 향기", "누룩과 꿀 금지", "소금 언약"]',
    chapter_context = '곡물로 드리는 소제는 감사와 헌신의 제사입니다. 누룩은 죄를, 소금은 언약의 영속성을 상징합니다.',
    chapter_application = '순수한 마음으로 감사를 드리고, 죄악을 멀리하며, 하나님과의 언약을 영원히 지켜야 합니다.'
WHERE book_id = 'lv' AND chapter = 2 AND verse = 1;

-- 레위기 3장: 화목제 규례
UPDATE bible_verses SET
    chapter_title = '화목제 규례',
    chapter_summary = '소, 양, 염소로 드리는 화목제의 규례가 주어집니다. 흠 없는 것을 안수하여 잡고 피는 제단 주위에 뿌리며, 기름과 내장을 태워 여호와께 향기로운 냄새로 드립니다. 기름과 피는 먹지 말라는 영원한 규례가 주어집니다.',
    chapter_themes = '["화목제 규례", "피 뿌림", "기름과 내장을 태움", "기름과 피 금식", "하나님과의 화목"]',
    chapter_context = '화목제는 하나님과의 평화와 교제를 상징하는 제사입니다. 제사장과 드리는 자가 함께 먹는 교제의 성격이 강합니다.',
    chapter_application = '하나님과 화목하며 교제하고, 거룩한 것과 속된 것을 구별하며, 생명이신 하나님을 경외해야 합니다.'
WHERE book_id = 'lv' AND chapter = 3 AND verse = 1;

-- 레위기 4장: 속죄제 규례
UPDATE bible_verses SET
    chapter_title = '속죄제 규례',
    chapter_summary = '실수로 죄를 범했을 때 드리는 속죄제의 규례가 주어집니다. 기름 부음 받은 제사장, 온 회중, 족장, 일반 백성에 따라 제물과 절차가 다르며, 피를 성소에 뿌리거나 제단 뿔에 바르고 나머지는 제단 밑에 쏟습니다.',
    chapter_themes = '["속죄제 규례", "실수로 범한 죄", "신분별 제물", "피의 속죄", "성소 정결"]',
    chapter_context = '죄의 등급과 신분에 따른 속죄 방법을 제시합니다. 피의 속죄가 핵심이며 그리스도의 보혈을 예표합니다.',
    chapter_application = '실수로 범한 죄도 반드시 속죄받아야 하며, 예수 그리스토의 보혈로만 죄 사함이 가능함을 믿어야 합니다.'
WHERE book_id = 'lv' AND chapter = 4 AND verse = 1;

-- 레위기 5장: 속건제 규례
UPDATE bible_verses SET
    chapter_title = '속건제 규례',
    chapter_summary = '특정한 죄들에 대한 속건제 규례가 주어집니다. 증언을 거부하거나 부정한 것을 만지거나 함부로 맹세한 경우 등에 양이나 염소를 드리되, 가난하면 비둘기나 고운 가루로도 드릴 수 있습니다.',
    chapter_themes = '["속건제 규례", "특정 죄들", "경제적 배려", "배상과 속죄", "죄의 고백"]',
    chapter_context = '개인의 경제적 능력을 고려한 하나님의 배려가 나타납니다. 죄에 대한 배상과 속죄가 함께 요구됩니다.',
    chapter_application = '어떤 죄든 숨기지 말고 고백하며, 능력에 따라 최선을 다해 하나님께 나아가고, 피해를 입힌 자에게 배상해야 합니다.'
WHERE book_id = 'lv' AND chapter = 5 AND verse = 1;

-- 레위기 6장: 제사장들을 위한 제사 규례
UPDATE bible_verses SET
    chapter_title = '제사장들을 위한 제사 규례',
    chapter_summary = '제사장들이 지켜야 할 번제, 소제, 속죄제의 세부 규례가 주어집니다. 제단의 불은 항상 피워두고, 소제의 남은 것은 제사장들이 먹되 누룩을 넣지 말고 거룩한 곳에서 먹어야 합니다.',
    chapter_themes = '["제사장 규례", "제단의 항상 타는 불", "거룩한 음식", "제사장의 분깃", "거룩한 곳에서 먹기"]',
    chapter_context = '제사장들의 직무 수행에 필요한 구체적 지침들입니다. 제단의 불이 꺼지지 않는 것은 하나님의 지속적 임재를 상징합니다.',
    chapter_application = '하나님을 섬기는 자는 항상 거룩함을 유지하고, 하나님의 임재의 불이 마음에서 꺼지지 않도록 해야 합니다.'
WHERE book_id = 'lv' AND chapter = 6 AND verse = 1;

-- 레위기 7장: 속건제와 화목제 추가 규례
UPDATE bible_verses SET
    chapter_title = '속건제와 화목제 추가 규례',
    chapter_summary = '속건제와 화목제에 대한 추가 규례가 주어집니다. 제사장의 분깃과 백성이 먹을 수 있는 부분, 먹어야 할 시간과 장소, 그리고 기름과 피를 먹으면 안 되는 영원한 규례가 강조됩니다.',
    chapter_themes = '["속건제 세부 규례", "화목제 음식법", "제사장 분깃", "기름과 피 금식", "부정한 자의 제한"]',
    chapter_context = '제사의 나눔과 정결에 대한 구체적 규정들입니다. 거룩한 제사에는 거룩한 참여가 필요함을 보여줍니다.',
    chapter_application = '하나님의 복을 나눌 때도 거룩하게 해야 하며, 부정한 상태에서는 거룩한 것에 참여하지 말아야 합니다.'
WHERE book_id = 'lv' AND chapter = 7 AND verse = 1;

-- 레위기 8장: 아론과 그 아들들의 위임식
UPDATE bible_verses SET
    chapter_title = '아론과 그 아들들의 위임식',
    chapter_summary = '하나님의 명령에 따라 모세가 아론과 그 아들들을 제사장으로 위임합니다. 물로 씻기고 거룩한 옷을 입히며 관유로 기름 부음을 하고, 위임제를 드려 7일간의 위임 기간을 보냅니다.',
    chapter_themes = '["제사장 위임식", "물로 씻김", "거룩한 옷", "기름 부음", "7일간의 성별"]',
    chapter_context = '출애굽기 29장의 명령이 실행되는 장면입니다. 제사장직의 시작을 알리는 중요한 의식입니다.',
    chapter_application = '하나님을 섬기는 직분은 정결함과 거룩함, 그리고 충분한 준비 기간이 필요하며, 하나님의 명령에 완전히 순종해야 합니다.'
WHERE book_id = 'lv' AND chapter = 8 AND verse = 1;

-- 레위기 9장: 첫 제사와 하나님의 영광
UPDATE bible_verses SET
    chapter_title = '첫 제사와 하나님의 영광',
    chapter_summary = '위임 기간이 끝난 후 아론이 처음으로 백성을 위해 제사를 드립니다. 자신과 백성을 위해 속죄제와 번제를 드린 후, 하나님의 영광이 모든 백성에게 나타나고 불이 나와서 제물을 사릅니다.',
    chapter_themes = '["첫 제사", "자신과 백성을 위한 속죄", "하나님의 영광", "하늘에서 내린 불", "백성의 경배"]',
    chapter_context = '제사 제도의 공식 시작을 알리는 역사적 순간입니다. 하나님의 임재와 인정하심이 불로 나타납니다.',
    chapter_application = '진실한 제사에는 하나님의 임재와 응답이 따르며, 하나님의 영광을 본 자는 겸손히 경배해야 합니다.'
WHERE book_id = 'lv' AND chapter = 9 AND verse = 1;

-- 레위기 10장: 나답과 아비후의 죽음
UPDATE bible_verses SET
    chapter_title = '나답과 아비후의 죽음',
    chapter_summary = '아론의 아들 나답과 아비후가 다른 불을 가져다가 여호와께서 명령하지 않은 향을 피우자, 여호와께로부터 불이 나와서 그들을 삼켜 죽입니다. 제사장들은 슬퍼하지도 말고 술을 마시지도 말며 거룩한 것과 속된 것을 구별하라고 명령받습니다.',
    chapter_themes = '["다른 불의 심판", "거룩함의 엄중성", "제사장의 절제", "거룩과 속의 구별", "교육의 책임"]',
    chapter_context = '거룩한 하나님 앞에서의 경솔함이 얼마나 위험한지 보여주는 사건입니다. 제사장직의 엄중함이 강조됩니다.',
    chapter_application = '하나님을 섬길 때 자의적이지 말고 하나님의 방법을 따라야 하며, 거룩함과 속됨을 분명히 구별해야 합니다.'
WHERE book_id = 'lv' AND chapter = 10 AND verse = 1;

-- 레위기 11장: 정결한 짐승과 부정한 짐승
UPDATE bible_verses SET
    chapter_title = '정결한 짐승과 부정한 짐승',
    chapter_summary = '먹을 수 있는 정결한 짐승과 먹을 수 없는 부정한 짐승을 구별하는 규례가 주어집니다. 땅의 짐승은 굽이 갈라지고 새김질하는 것, 물의 것은 지느러미와 비늘이 있는 것, 새 중에서는 독수리 등을 제외하고 먹을 수 있습니다.',
    chapter_themes = '["정결한 짐승", "부정한 짐승", "음식 구별법", "거룩한 백성", "하나님의 거룩하심"]',
    chapter_context = '이스라엘을 다른 민족들과 구별시키는 음식법입니다. 거룩한 백성으로서의 정체성을 형성하는 규례입니다.',
    chapter_application = '하나님의 백성은 세상과 구별된 삶을 살아야 하며, 몸과 마음에 해로운 것들을 분별하여 피해야 합니다.'
WHERE book_id = 'lv' AND chapter = 11 AND verse = 1;

-- 레위기 12장: 출산 후의 정결법
UPDATE bible_verses SET
    chapter_title = '출산 후의 정결법',
    chapter_summary = '여인이 남자를 낳으면 7일간, 여자를 낳으면 14일간 부정하며, 각각 33일과 66일간 정결케 되는 기간을 보내야 합니다. 정결 기간이 끝나면 번제와 속죄제를 드려 정결하게 됩니다.',
    chapter_themes = '["출산 후 정결법", "남녀 차별적 기간", "정결케 되는 기간", "번제와 속죄제", "새 생명의 거룩성"]',
    chapter_context = '생명 탄생과 관련된 정결 규례입니다. 예수님의 어머니 마리아도 이 규례를 따라 정결 예식을 행했습니다.',
    chapter_application = '새 생명은 하나님의 선물이므로 감사하며, 모든 인간은 죄인으로 태어나므로 구원이 필요함을 깨달아야 합니다.'
WHERE book_id = 'lv' AND chapter = 12 AND verse = 1;

-- 레위기 13장: 나병 진단법
UPDATE bible_verses SET
    chapter_title = '나병 진단법',
    chapter_summary = '피부병, 특히 나병을 진단하는 제사장의 규례가 자세히 주어집니다. 털이 희어지고 피부가 우묵해지면 부정하며, 의심스러우면 7일간 격리하여 관찰합니다. 옷에 생긴 곰팡이에 대한 규례도 포함됩니다.',
    chapter_themes = '["나병 진단", "제사장의 의료 역할", "격리와 관찰", "정결과 부정", "옷의 곰팡이"]',
    chapter_context = '고대 이스라엘의 공중보건법이면서 동시에 죄의 상징인 나병에 대한 규례입니다. 제사장이 의사 역할도 했습니다.',
    chapter_application = '죄는 나병처럼 전염성이 있으므로 조심해야 하며, 의심스러운 것은 영적 지도자의 도움을 받아 분별해야 합니다.'
WHERE book_id = 'lv' AND chapter = 13 AND verse = 1;

-- 레위기 14장: 나병환자의 정결법
UPDATE bible_verses SET
    chapter_title = '나병환자의 정결법',
    chapter_summary = '나병이 나은 자의 정결 의식이 상세히 기록됩니다. 두 마리 새 중 하나는 잡아 그 피로 정결케 하고 다른 하나는 놓아주며, 7일 후에 삭발하고 제사를 드려 완전히 정결하게 됩니다. 집에 생긴 곰팡이 처리법도 포함됩니다.',
    chapter_themes = '["나병 치유 후 정결법", "두 새의 의식", "삭발과 정결", "집의 곰팡이 처리", "완전한 회복"]',
    chapter_context = '죄에서의 구원과 회복 과정을 상징적으로 보여줍니다. 두 새의 의식은 그리스도의 죽음과 부활을 예표합니다.',
    chapter_application = '죄에서 구원받은 후에도 지속적인 정결과정이 필요하며, 완전한 회복을 위해 하나님께 감사의 제사를 드려야 합니다.'
WHERE book_id = 'lv' AND chapter = 14 AND verse = 1;

-- 레위기 15장: 유출병에 관한 정결법
UPDATE bible_verses SET
    chapter_title = '유출병에 관한 정결법',
    chapter_summary = '남녀의 생식기 유출에 관한 정결 규례가 주어집니다. 정상적이거나 비정상적인 유출 모두 일정 기간 부정하며, 접촉한 사람이나 물건도 부정해집니다. 정결해진 후에는 제사를 드려야 합니다.',
    chapter_themes = '["유출병 정결법", "남녀 생식기 문제", "접촉으로 인한 부정", "정결 후 제사", "성적 순결성"]',
    chapter_context = '인간의 성적 영역도 하나님의 거룩하심 앞에서 정결해야 함을 보여줍니다. 생명과 관련된 영역의 거룩성을 강조합니다.',
    chapter_application = '몸의 모든 영역이 거룩해야 하며, 성적 순결을 지키고, 부정한 것에 접촉했을 때는 정결케 되어야 합니다.'
WHERE book_id = 'lv' AND chapter = 15 AND verse = 1;

-- 레위기 16장: 대속죄일
UPDATE bible_verses SET
    chapter_title = '대속죄일',
    chapter_summary = '일 년에 한 번 지성소에 들어가는 대속죄일의 규례가 주어집니다. 대제사장이 자신과 백성을 위해 속죄제를 드리고, 두 염소 중 하나는 여호와를 위한 속죄제로, 다른 하나는 아사셀을 위해 광야로 보냅니다.',
    chapter_themes = '["대속죄일", "지성소 입장", "두 염소", "아사셀 염소", "일년일차 속죄"]',
    chapter_context = '구약에서 가장 중요한 속죄 의식으로, 그리스도의 완전한 속죄 사역을 예표합니다. 히브리서의 배경이 됩니다.',
    chapter_application = '죄는 완전한 속죄가 필요하며, 예수 그리스도만이 우리의 영원한 대제사장이시므로 그분을 통해서만 하나님께 나아갈 수 있습니다.'
WHERE book_id = 'lv' AND chapter = 16 AND verse = 1;

-- 레위기 17장: 피에 관한 규례
UPDATE bible_verses SET
    chapter_title = '피에 관한 규례',
    chapter_summary = '짐승을 잡을 때는 반드시 회막 문에서 여호와께 제사로 드려야 하며, 들에서 잡아 피를 흘리면 안 됩니다. 피는 생명이므로 먹지 말고 땅에 쏟아 흙으로 덮어야 합니다.',
    chapter_themes = '["피의 거룩성", "생명은 피에 있음", "제사 장소 규정", "우상 제사 금지", "피 먹는 것 금지"]',
    chapter_context = '피의 신성함과 생명의 존엄성을 강조합니다. 모든 생명이 하나님께 속함을 보여주는 규례입니다.',
    chapter_application = '생명을 귀하게 여기고, 그리스도의 보혈의 소중함을 깨달으며, 하나님이 정하신 방법으로만 하나님께 나아가야 합니다.'
WHERE book_id = 'lv' AND chapter = 17 AND verse = 1;

-- 레위기 18장: 성적 도덕법
UPDATE bible_verses SET
    chapter_title = '성적 도덕법',
    chapter_summary = '근친상간, 간음, 동성애, 수간 등 금지된 성관계에 대한 규례가 주어집니다. 이런 일들로 인해 가나안 족속들이 그 땅에서 쫓겨났으며, 이스라엘도 이런 일을 행하면 그 땅이 그들을 토할 것이라고 경고합니다.',
    chapter_themes = '["성적 금기", "근친상간 금지", "간음 금지", "동성애 금지", "가나안 족속의 죄"]',
    chapter_context = '가나안 정착을 앞둔 이스라엘에게 주어진 성적 순결법입니다. 거룩한 백성으로서의 구별된 성윤리를 요구합니다.',
    chapter_application = '성적 순결을 지키고, 하나님이 정하신 결혼 제도를 존중하며, 세상의 타락한 문화를 따르지 말아야 합니다.'
WHERE book_id = 'lv' AND chapter = 18 AND verse = 1;

-- 레위기 19장: 거룩한 생활 규례
UPDATE bible_verses SET
    chapter_title = '거룩한 생활 규례',
    chapter_summary = '여호와께서 거룩하시니 너희도 거룩하라는 명령과 함께 구체적인 거룩한 생활 규례들이 주어집니다. 부모 공경, 안식일 준수, 우상 숭배 금지, 가난한 자 구제, 정직한 재판, 이웃 사랑 등이 포함됩니다.',
    chapter_themes = '["거룩한 삶", "부모 공경", "가난한 자 구제", "정직한 재판", "이웃 사랑"]',
    chapter_context = '거룩 법전의 핵심으로 "네 이웃을 네 자신 같이 사랑하라"는 예수님이 인용하신 말씀이 나옵니다.',
    chapter_application = '하나님의 거룩하심을 본받아 모든 삶의 영역에서 거룩하게 살고, 특히 이웃을 자신같이 사랑해야 합니다.'
WHERE book_id = 'lv' AND chapter = 19 AND verse = 1;

-- 레위기 20장: 거룩 법전의 처벌 규정
UPDATE bible_verses SET
    chapter_title = '거룩 법전의 처벌 규정',
    chapter_summary = '몰렉에게 자녀를 바치는 자, 무당과 박수를 찾는 자, 부모를 저주하는 자, 간음하는 자, 근친상간하는 자, 동성애자, 수간하는 자 등에 대한 사형 처벌 규정이 주어집니다. 거룩한 백성이 되어 다른 민족들과 구별되라고 명령합니다.',
    chapter_themes = '["사형 처벌 규정", "몰렉 숭배 금지", "무당 박수 금지", "성적 타락 처벌", "거룩한 구별"]',
    chapter_context = '18-19장의 도덕법에 대한 처벌 규정입니다. 거룩함의 중요성과 죄의 심각성을 보여줍니다.',
    chapter_application = '죄의 결과가 얼마나 심각한지 깨닫고, 거룩한 백성으로서 세상과 구별된 삶을 살며, 하나님의 법을 경외해야 합니다.'
WHERE book_id = 'lv' AND chapter = 20 AND verse = 1;

-- 레위기 21장: 제사장의 거룩 규례
UPDATE bible_verses SET
    chapter_title = '제사장의 거룩 규례',
    chapter_summary = '제사장들이 지켜야 할 특별한 거룩 규례가 주어집니다. 죽은 자로 인해 몸을 더럽히지 말고, 머리를 삭발하거나 수염을 깎지 말며, 창기나 이혼한 여자와 결혼하지 말아야 합니다. 대제사장에게는 더욱 엄격한 규정이 적용됩니다.',
    chapter_themes = '["제사장 거룩 규례", "죽은 자로 인한 부정 금지", "창기와 결혼 금지", "대제사장의 특별 규정", "육체적 흠 없는 제사장"]',
    chapter_context = '하나님을 섬기는 제사장들에게 요구되는 더 높은 차원의 거룩함입니다. 그리스도의 완전한 제사장직을 예표합니다.',
    chapter_application = '하나님을 섬기는 자는 더욱 거룩한 삶을 살아야 하며, 완전하신 예수 그리스도만이 참된 대제사장이심을 믿어야 합니다.'
WHERE book_id = 'lv' AND chapter = 21 AND verse = 1;

-- 레위기 22장: 거룩한 제물에 관한 규례
UPDATE bible_verses SET
    chapter_title = '거룩한 제물에 관한 규례',
    chapter_summary = '제사장과 그 가족이 거룩한 제물을 먹을 때의 규례가 주어집니다. 부정한 자는 먹지 못하고, 외국인이나 나그네, 품꾼은 먹지 못하지만 제사장의 종이나 딸은 먹을 수 있습니다. 제물은 흠 없는 것이어야 합니다.',
    chapter_themes = '["거룩한 제물", "부정한 자 먹기 금지", "외국인 제한", "흠 없는 제물", "제사장 가족의 권리"]',
    chapter_context = '거룩한 것과 속된 것의 구별이 제물을 먹는 일에도 적용됩니다. 거룩함의 전수성과 배타성을 보여줍니다.',
    chapter_application = '하나님의 거룩한 은혜에 참여할 자격을 갖추어야 하며, 흠 없으신 예수 그리스도만이 완전한 제물이심을 믿어야 합니다.'
WHERE book_id = 'lv' AND chapter = 22 AND verse = 1;

-- 레위기 23장: 여호와의 절기들
UPDATE bible_verses SET
    chapter_title = '여호와의 절기들',
    chapter_summary = '이스라엘이 지켜야 할 여호와의 절기들이 규정됩니다. 안식일, 유월절, 무교절, 초실절, 칠칠절(오순절), 나팔절, 속죄일, 초막절 등이 포함되며, 각 절기의 날짜와 지켜야 할 규례들이 자세히 설명됩니다.',
    chapter_themes = '["여호와의 절기", "안식일", "유월절과 무교절", "초실절", "칠칠절", "나팔절", "속죄일", "초막절"]',
    chapter_context = '이스라엘의 종교력과 절기 체계가 확립됩니다. 각 절기는 구원사적 의미와 그리스도의 사역을 예표합니다.',
    chapter_application = '하나님이 정하신 때를 구별하여 지키고, 절기의 영적 의미를 깨달아 그리스도 안에서 성취된 구원을 감사해야 합니다.'
WHERE book_id = 'lv' AND chapter = 23 AND verse = 1;

-- 레위기 24장: 성막의 등불과 하나님 이름을 모독한 자
UPDATE bible_verses SET
    chapter_title = '성막의 등불과 하나님 이름을 모독한 자',
    chapter_summary = '성막의 등불을 항상 켜두고 진설병을 매 안식일마다 새것으로 바꾸라는 규례와, 이스라엘 여인과 이집트 남자 사이에서 난 아들이 하나님의 이름을 모독하고 저주했을 때 돌로 쳐 죽이라는 판결이 내려집니다.',
    chapter_themes = '["성막의 등불", "진설병", "하나님 이름 모독", "동해보복법", "이방인과의 혼혈"]',
    chapter_context = '하나님의 이름의 거룩함과 신성모독죄의 심각성을 보여줍니다. 등불과 진설병은 하나님의 지속적 임재를 상징합니다.',
    chapter_application = '하나님의 이름을 거룩히 여기고, 하나님의 임재의 빛이 항상 우리 마음에 있도록 하며, 죄의 결과를 심각하게 받아들여야 합니다.'
WHERE book_id = 'lv' AND chapter = 24 AND verse = 1;

-- 레위기 25장: 안식년과 희년
UPDATE bible_verses SET
    chapter_title = '안식년과 희년',
    chapter_summary = '7년마다 안식년을 지켜 땅을 쉬게 하고, 7번의 안식년 후 50년째를 희년으로 지켜 종들을 해방시키고 땅을 원래 주인에게 돌려주라고 합니다. 가난한 자에게 이자를 받지 말고 도와주라는 규례도 포함됩니다.',
    chapter_themes = '["안식년", "희년", "종의 해방", "토지 반환", "가난한 자 구제", "이자 금지"]',
    chapter_context = '사회 정의와 경제 평등을 위한 혁신적 제도입니다. 모든 것이 하나님께 속함을 인정하는 신앙고백입니다.',
    chapter_application = '모든 것이 하나님의 것임을 인정하고, 사회적 약자를 돌보며, 탐욕을 버리고 나눔을 실천해야 합니다.'
WHERE book_id = 'lv' AND chapter = 25 AND verse = 1;

-- 레위기 26장: 순종의 복과 불순종의 저주
UPDATE bible_verses SET
    chapter_title = '순종의 복과 불순종의 저주',
    chapter_summary = '하나님의 법을 지키면 비를 주시고 땅이 소산을 내며 평안과 번영을 주시지만, 불순종하면 질병과 기근, 전쟁과 포로됨의 저주가 임할 것이라고 경고합니다. 그러나 회개하면 아브라함과 맺은 언약을 기억하셨다가 회복시켜 주십니다.',
    chapter_themes = '["순종의 복", "불순종의 저주", "회개와 회복", "아브라함 언약", "하나님의 신실하심"]',
    chapter_context = '레위기의 결론으로 순종과 불순종의 결과를 명확히 제시합니다. 이스라엘 역사에서 실제로 성취된 예언입니다.',
    chapter_application = '하나님의 말씀에 순종하여 복을 받고, 불순종의 결과를 두려워하며, 실패해도 회개하면 하나님의 언약적 사랑으로 회복됨을 믿어야 합니다.'
WHERE book_id = 'lv' AND chapter = 26 AND verse = 1;

-- 레위기 27장: 서원과 십일조
UPDATE bible_verses SET
    chapter_title = '서원과 십일조',
    chapter_summary = '사람이나 짐승이나 전을 여호와께 서원하여 드릴 때의 값어치 규정과 속전에 관한 규례가 주어집니다. 십일조는 여호와의 것이므로 속하려면 그 오분의 일을 더하여 내야 하며, 처음 난 것은 이미 여호와의 것이므로 서원할 수 없습니다.',
    chapter_themes = '["서원 규례", "속전 규정", "십일조", "처음 난 것", "하나님께 드리는 헌신"]',
    chapter_context = '레위기의 마지막 장으로 자발적 헌신에 대한 규례입니다. 하나님께 드리는 것의 신성함을 강조합니다.',
    chapter_application = '하나님께 드린 서원은 반드시 지켜야 하며, 십일조와 헌물을 통해 하나님의 주권을 인정하고 감사를 표현해야 합니다.'
WHERE book_id = 'lv' AND chapter = 27 AND verse = 1;