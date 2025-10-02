-- 출애굽기 전체 해석 데이터 (Exodus Commentary)
-- 이스라엘의 이집트 탈출과 시내산에서의 언약 체결을 다루는 구원사의 핵심

-- 출애굽기 1장: 이스라엘의 고난
UPDATE bible_verses SET
    chapter_title = '이스라엘의 고난과 번성',
    chapter_summary = '이집트에서 번성한 이스라엘 민족이 새로운 바로에 의해 억압받기 시작합니다. 바로는 이스라엘의 번식을 두려워하여 노예로 부리며, 산파들에게 남자 아기를 죽이라 명령하지만 하나님을 경외하는 산파들이 이를 거부합니다.',
    chapter_themes = '["이스라엘 번성", "이집트 압제", "하나님을 경외하는 산파", "구원의 전조", "바로의 두려움"]',
    chapter_context = '야곱의 후손들이 약 400년간 이집트에 거주하며 큰 민족으로 성장했습니다. 요셉을 알지 못하는 새 바로가 등장하면서 이스라엘에 대한 정책이 완전히 바뀝니다.',
    chapter_application = '하나님의 약속은 어떤 상황에서도 성취되며, 의인은 불의한 명령에 순종하지 않아야 함을 보여줍니다. 어려운 상황에서도 하나님을 경외하는 마음을 잃지 말아야 합니다.'
WHERE book_id = 'ex' AND chapter = 1 AND verse = 1;

-- 출애굽기 2장: 모세의 출생과 피난
UPDATE bible_verses SET
    chapter_title = '모세의 출생과 미디안 피난',
    chapter_summary = '레위 가정에서 모세가 태어나 나일강에 버려졌으나 바로의 딸에게 발견되어 왕실에서 자랍니다. 성인이 된 모세는 이집트인이 히브리인을 때리는 것을 보고 이집트인을 죽인 후 미디안으로 피신하여 이드로의 사위가 됩니다.',
    chapter_themes = '["모세의 구원", "하나님의 섭리", "정의감", "피신과 은둔", "이드로와의 만남"]',
    chapter_context = '모세의 출생과 구원은 하나님의 구원 계획의 시작을 보여줍니다. 왕실 교육을 받은 모세가 자신의 민족 의식을 갖게 되는 과정이 기록됩니다.',
    chapter_application = '하나님은 당신의 계획을 위해 사람을 준비시키시며, 때로는 광야의 시간을 통해 성숙시키십니다. 성급한 의협심보다 하나님의 때를 기다리는 지혜가 필요합니다.'
WHERE book_id = 'ex' AND chapter = 2 AND verse = 1;

-- 출애굽기 3장: 불타는 떨기나무의 소명
UPDATE bible_verses SET
    chapter_title = '불타는 떨기나무의 소명',
    chapter_summary = '하나님께서 호렙산의 불타는 떨기나무 가운데서 모세를 부르시며 이스라엘을 이집트에서 구원하라는 사명을 주십니다. 모세는 자신의 부족함을 들어 거부하지만, 하나님은 당신의 이름을 "스스로 있는 자"(야훼)라고 계시하시며 확신을 주십니다.',
    chapter_themes = '["하나님의 소명", "거룩한 땅", "야훼 계시", "모세의 겸손", "구원의 약속"]',
    chapter_context = '구약에서 가장 중요한 하나님의 자기 계시 중 하나입니다. "나는 스스로 있는 자"(에흐예 아쉐르 에흐예)라는 하나님의 이름이 최초로 계시됩니다.',
    chapter_application = '하나님의 부르심 앞에서 겸손하되 하나님의 능력을 신뢰해야 합니다. 하나님은 완전한 분이시므로 우리의 부족함을 통해서도 역사하실 수 있습니다.'
WHERE book_id = 'ex' AND chapter = 3 AND verse = 1;

-- 출애굽기 4장: 하나님의 표징과 아론의 협력
UPDATE bible_verses SET
    chapter_title = '하나님의 표징과 아론의 협력',
    chapter_summary = '하나님께서 모세에게 지팡이가 뱀이 되는 표징과 손이 나병이 되었다가 낫는 표징을 주시며, 말 못함을 핑계대는 모세에게 형 아론을 대변자로 세워주십니다. 모세는 가족을 데리고 이집트로 돌아갑니다.',
    chapter_themes = '["하나님의 표징", "아론의 협력", "이집트 귀환", "할례의 중요성", "가족의 동행"]',
    chapter_context = '하나님의 사역에는 협력자가 필요함을 보여줍니다. 모세의 아내 십보라가 아들에게 할례를 행하는 사건은 언약의 중요성을 강조합니다.',
    chapter_application = '하나님은 우리의 약점을 보완할 동역자를 세워주십니다. 하나님의 사역에는 순종과 더불어 언약에 대한 신실함이 필요합니다.'
WHERE book_id = 'ex' AND chapter = 4 AND verse = 1;

-- 출애굽기 5장: 바로의 첫 번째 거부
UPDATE bible_verses SET
    chapter_title = '바로의 첫 번째 거부와 백성의 원망',
    chapter_summary = '모세와 아론이 바로에게 이스라엘을 보내달라고 요청하지만 바로는 거부하며 오히려 이스라엘의 노역을 더 무겁게 합니다. 짚을 주지 않으면서도 벽돌 수는 그대로 만들라고 명령하여 백성들이 모세를 원망합니다.',
    chapter_themes = '["바로의 거부", "노역 가중", "백성의 원망", "첫 번째 시련", "믿음의 시험"]',
    chapter_context = '구원 사역의 초기 좌절을 보여줍니다. 때로는 하나님의 사역이 시작될 때 상황이 더 어려워질 수 있음을 알려줍니다.',
    chapter_application = '하나님의 뜻을 행할 때 처음에는 더 큰 어려움이 올 수 있지만, 이는 하나님의 더 큰 역사를 위한 과정임을 믿어야 합니다.'
WHERE book_id = 'ex' AND chapter = 5 AND verse = 1;

-- 출애굽기 6장: 하나님의 언약 재확인
UPDATE bible_verses SET
    chapter_title = '하나님의 언약 재확인과 족보',
    chapter_summary = '하나님께서 모세에게 아브라함, 이삭, 야곱과 맺은 언약을 기억하시며 이스라엘을 구원하겠다고 재확인하십니다. 모세와 아론의 족보가 기록되어 그들의 정통성을 확립합니다.',
    chapter_themes = '["언약 재확인", "하나님의 신실함", "족보와 정통성", "구원의 확신", "야훼의 이름"]',
    chapter_context = '좌절 가운데서 하나님의 신실하심을 재확인시켜 주는 장입니다. 족보를 통해 모세와 아론의 사역에 정당성을 부여합니다.',
    chapter_application = '어려운 상황에서도 하나님의 약속은 변하지 않으며, 하나님은 당신의 언약을 반드시 성취하시는 신실한 분임을 믿어야 합니다.'
WHERE book_id = 'ex' AND chapter = 6 AND verse = 1;

-- 출애굽기 7장: 첫 번째 재앙 - 피 재앙
UPDATE bible_verses SET
    chapter_title = '첫 번째 재앙 - 피 재앙',
    chapter_summary = '하나님께서 바로의 마음을 강퍅하게 하시고 애굽에 재앙을 내리기 시작하십니다. 아론이 나일강을 지팡이로 치자 강물이 피로 변하여 물고기가 죽고 물을 마실 수 없게 됩니다. 그러나 바로의 마음은 강퍅해집니다.',
    chapter_themes = '["첫 번째 재앙", "나일강의 저주", "하나님의 권능", "바로의 강퍅함", "이집트 신들에 대한 심판"]',
    chapter_context = '이집트의 생명선인 나일강을 치심으로 이집트의 신 하피에 대한 하나님의 우월성을 보여줍니다. 열 재앙의 서막입니다.',
    chapter_application = '하나님은 당신을 대적하는 모든 권세와 우상을 심판하십니다. 하나님의 경고에 회개하지 않으면 더 큰 심판이 따름을 알아야 합니다.'
WHERE book_id = 'ex' AND chapter = 7 AND verse = 1;

-- 출애굽기 8장: 개구리, 이, 파리 재앙
UPDATE bible_verses SET
    chapter_title = '개구리, 이, 파리 재앙',
    chapter_summary = '둘째 재앙으로 개구리가 온 땅에 올라와 집안까지 들어가고, 셋째 재앙으로 티끌이 이가 되어 사람과 짐승을 괴롭히며, 넷째 재앙으로 파리 떼가 이집트 전역을 덮습니다. 바로가 일시적으로 타협하려 하지만 재앙이 그치자 마음을 돌이킵니다.',
    chapter_themes = '["연속된 재앙", "바로의 일시적 타협", "고센 땅의 구별", "이집트 전역의 고통", "하나님의 점진적 심판"]',
    chapter_context = '재앙이 점점 심화되면서 이집트 전체가 고통받지만 이스라엘이 거주하는 고센 땅은 보호받습니다. 하나님의 백성에 대한 특별한 보호를 보여줍니다.',
    chapter_application = '하나님은 당신의 백성을 세상과 구별하여 보호하십니다. 일시적인 타협이 아닌 진정한 회개와 순종이 필요합니다.'
WHERE book_id = 'ex' AND chapter = 8 AND verse = 1;

-- 출애굽기 9장: 가축 전염병, 독종, 우박 재앙
UPDATE bible_verses SET
    chapter_title = '가축 전염병, 독종, 우박 재앙',
    chapter_summary = '다섯째 재앙으로 이집트의 모든 가축이 전염병으로 죽고, 여섯째 재앙으로 사람과 짐승에게 독종이 나며, 일곱째 재앙으로 무서운 우박이 내려 사람과 짐승과 채소를 다 치지만 고센 땅은 피해를 입지 않습니다.',
    chapter_themes = '["가축 전염병", "독종과 질병", "우박 재앙", "고센 땅 보호", "바로의 일시적 고백"]',
    chapter_context = '재앙이 더욱 심화되어 이집트의 경제적 기반인 가축들이 죽고, 사람들도 직접적인 고통을 당합니다. 하나님의 백성에 대한 구별이 더욱 명확해집니다.',
    chapter_application = '하나님의 심판은 점진적으로 강화되지만, 당신의 백성은 보호하십니다. 진정한 회개 없이는 일시적인 고백으로 끝날 수 있음을 경계해야 합니다.'
WHERE book_id = 'ex' AND chapter = 9 AND verse = 1;

-- 출애굽기 10장: 메뚜기와 흑암 재앙
UPDATE bible_verses SET
    chapter_title = '메뚜기와 흑암 재앙',
    chapter_summary = '여덟째 재앙으로 메뚜기 떼가 와서 우박에 살아남은 모든 채소를 먹어치우고, 아홉째 재앙으로 3일간 짙은 어둠이 이집트를 덮어 사람들이 서로 볼 수 없게 됩니다. 바로가 조건부 허락을 하려 하지만 모세는 거부합니다.',
    chapter_themes = '["메뚜기 재앙", "흑암 재앙", "완전한 파괴", "조건부 타협", "빛과 어둠의 구별"]',
    chapter_context = '이집트의 농업이 완전히 파괴되고 태양신 라에 대한 하나님의 우월성이 드러납니다. 바로는 여전히 완전한 항복을 거부합니다.',
    chapter_application = '하나님과의 관계에서 조건부 순종이나 부분적 헌신은 받아들여지지 않습니다. 완전한 순종과 헌신이 요구됩니다.'
WHERE book_id = 'ex' AND chapter = 10 AND verse = 1;

-- 출애굽기 11장: 마지막 재앙 예고
UPDATE bible_verses SET
    chapter_title = '마지막 재앙 예고',
    chapter_summary = '하나님께서 마지막 열 번째 재앙을 예고하십니다. 이집트의 모든 장자가 죽을 것이며, 이 후에 바로가 이스라엘을 보낼 것이라고 하십니다. 이집트 사람들이 이스라엘에게 금은 보석을 내어줄 것도 예언하십니다.',
    chapter_themes = '["마지막 재앙 예고", "장자의 죽음", "완전한 해방", "이집트의 굴복", "하나님의 최종 심판"]',
    chapter_context = '열 재앙의 절정을 예고하는 장입니다. 이집트의 후계 구조 자체를 무너뜨리는 심판이 선언됩니다.',
    chapter_application = '하나님의 인내에는 한계가 있으며, 지속적인 불순종은 결국 돌이킬 수 없는 심판을 초래함을 알아야 합니다.'
WHERE book_id = 'ex' AND chapter = 11 AND verse = 1;

-- 출애굽기 12장: 유월절과 출애굽
UPDATE bible_verses SET
    chapter_title = '유월절과 출애굽',
    chapter_summary = '하나님께서 유월절 규례를 제정하시고, 이스라엘 백성들이 문설주에 어린 양의 피를 바르고 어린 양을 구워 먹습니다. 밤중에 이집트의 모든 장자가 죽자 바로가 이스라엘을 보내며, 이스라엘이 430년 만에 이집트에서 나옵니다.',
    chapter_themes = '["유월절 제정", "어린 양의 피", "장자의 죽음", "430년 만의 해방", "출애굽의 실현"]',
    chapter_context = '구약의 가장 중요한 절기인 유월절이 제정됩니다. 어린 양의 피는 그리스도의 십자가 희생을 예표합니다.',
    chapter_application = '구원은 하나님의 어린 양의 피로만 가능하며, 이를 믿음으로 받아들이는 자에게 죽음이 넘어갑니다. 구원의 은혜를 기억하고 기념해야 합니다.'
WHERE book_id = 'ex' AND chapter = 12 AND verse = 1;

-- 출애굽기 13장: 장자 성별과 출발
UPDATE bible_verses SET
    chapter_title = '장자 성별과 출발',
    chapter_summary = '하나님께서 이스라엘의 모든 장자를 거룩히 구별하라 하시고, 출애굽의 역사를 후대에 전하라 명하십니다. 이스라엘이 이집트에서 나와 구름 기둥과 불기둥의 인도를 받으며 광야로 향합니다.',
    chapter_themes = '["장자 성별", "후대 교육", "구름과 불기둥", "하나님의 인도", "약속 땅을 향한 여정"]',
    chapter_context = '구원받은 백성의 의무와 하나님의 지속적인 인도하심을 보여줍니다. 교육의 중요성이 강조됩니다.',
    chapter_application = '구원받은 자는 하나님께 속한 거룩한 존재이며, 구원의 역사를 후대에 전수해야 할 책임이 있습니다.'
WHERE book_id = 'ex' AND chapter = 13 AND verse = 1;

-- 출애굽기 14장: 홍해 도하
UPDATE bible_verses SET
    chapter_title = '홍해 도하',
    chapter_summary = '바로가 마음을 돌이켜 군대를 이끌고 이스라엘을 추격합니다. 홍해 앞에서 진퇴양난에 빠진 이스라엘을 위해 하나님께서 바다를 갈라 마른 땅으로 건너게 하시고, 추격하는 이집트 군대는 바다에 수장됩니다.',
    chapter_themes = '["홍해 도하", "바로의 추격", "하나님의 기적", "이집트 군대의 수장", "완전한 구원"]',
    chapter_context = '구약 역사상 가장 극적인 구원 사건입니다. 물의 갈라짐은 하나님의 창조 권능을 보여주며, 세례의 예표가 됩니다.',
    chapter_application = '절망적인 상황에서도 하나님은 길을 만드시며, 과거의 죄와 속박에서 완전히 자유롭게 하십니다.'
WHERE book_id = 'ex' AND chapter = 14 AND verse = 1;

-- 출애굽기 15장: 승리의 노래
UPDATE bible_verses SET
    chapter_title = '승리의 노래',
    chapter_summary = '모세와 이스라엘 백성들이 홍해 구원을 기념하여 하나님께 승리의 노래를 부르고, 미리암이 여인들과 함께 소고를 잡고 춤추며 찬양합니다. 그 후 광야에서 쓴 물 마라를 단 물로 바꾸는 기적을 경험합니다.',
    chapter_themes = '["승리의 노래", "미리암의 찬양", "마라의 기적", "하나님을 의사로 계시", "광야에서의 첫 시험"]',
    chapter_context = '구원 후의 첫 번째 찬양과 광야에서의 첫 번째 시험을 기록합니다. 찬양과 시련이 함께 나타남을 보여줍니다.',
    chapter_application = '하나님의 구원에 대해 찬양하되, 광야의 시련 가운데서도 하나님을 신뢰해야 합니다. 하나님은 우리의 치료자이십니다.'
WHERE book_id = 'ex' AND chapter = 15 AND verse = 1;

-- 출애굽기 16장: 만나와 메추라기
UPDATE bible_verses SET
    chapter_title = '만나와 메추라기',
    chapter_summary = '광야에서 양식이 떨어지자 백성들이 원망하며 이집트를 그리워합니다. 하나님께서 저녁에는 메추라기를, 아침에는 만나를 내려주시며 안식일 규례도 주십니다. 만나는 40년간 이스라엘의 양식이 됩니다.',
    chapter_themes = '["만나와 메추라기", "하나님의 공급", "안식일 규례", "백성의 원망", "하나님의 시험"]',
    chapter_context = '광야에서 하나님의 일용할 양식 공급과 안식일 개념이 도입됩니다. 하나님에 대한 신뢰의 훈련 과정입니다.',
    chapter_application = '하나님은 우리의 일용할 양식을 책임지시며, 물질보다 하나님의 말씀으로 사는 삶의 우선순위를 배워야 합니다.'
WHERE book_id = 'ex' AND chapter = 16 AND verse = 1;

-- 출애굽기 17장: 반석에서 나온 물과 아말렉과의 전투
UPDATE bible_verses SET
    chapter_title = '반석에서 나온 물과 아말렉과의 전투',
    chapter_summary = '르비딤에서 물이 없자 백성들이 또 원망하며 하나님을 시험합니다. 모세가 반석을 치자 물이 나오고, 아말렉이 쳐들어오자 여호수아가 싸우고 모세가 손을 들고 기도하여 승리합니다.',
    chapter_themes = '["반석에서 나온 물", "백성의 시험", "아말렉과의 전투", "기도의 능력", "여호수아의 등장"]',
    chapter_context = '반석에서 나온 물은 그리스도를 예표하며, 아말렉과의 전투는 영적 전쟁의 원형을 보여줍니다. 기도의 중요성이 강조됩니다.',
    chapter_application = '어려움 중에 하나님을 원망하지 말고, 기도로 하나님께 의지해야 합니다. 영적 전쟁에서 기도는 필수적입니다.'
WHERE book_id = 'ex' AND chapter = 17 AND verse = 1;

-- 출애굽기 18장: 이드로의 조언
UPDATE bible_verses SET
    chapter_title = '이드로의 조언',
    chapter_summary = '모세의 장인 이드로가 모세의 아내와 두 아들을 데리고 와서 모세가 혼자 모든 백성의 송사를 처리하는 것을 보고 조언합니다. 이드로는 천부장, 백부장 등을 세워 재판 체계를 만들라고 권합니다.',
    chapter_themes = '["이드로의 지혜", "행정 체계 구축", "권한 위임", "효율적 관리", "가족의 재회"]',
    chapter_context = '지도자의 효율적인 관리 체계에 대한 지혜를 보여줍니다. 외부인의 조언도 겸손히 받아들이는 모세의 모습이 나타납니다.',
    chapter_application = '지도자는 모든 일을 혼자 하려 하지 말고 적절히 권한을 위임해야 하며, 좋은 조언은 겸손히 받아들여야 합니다.'
WHERE book_id = 'ex' AND chapter = 18 AND verse = 1;

-- 출애굽기 19장: 시내산에서의 언약 준비
UPDATE bible_verses SET
    chapter_title = '시내산에서의 언약 준비',
    chapter_summary = '이스라엘이 시내산에 도착하여 하나님께서 이스라엘을 제사장 나라, 거룩한 백성으로 삼으시겠다고 약속하십니다. 백성들이 정결 예식을 거행하고 산을 정결케 하여 하나님의 강림을 준비합니다.',
    chapter_themes = '["제사장 나라", "거룩한 백성", "언약 준비", "정결 예식", "하나님의 강림 준비"]',
    chapter_context = '시내산 언약의 시작으로, 이스라엘의 정체성과 사명이 선언됩니다. 하나님과의 만남을 위한 준비 과정이 중요합니다.',
    chapter_application = '하나님의 백성은 제사장적 역할과 거룩한 삶을 살아야 하며, 하나님과의 만남을 위해 정결한 준비가 필요합니다.'
WHERE book_id = 'ex' AND chapter = 19 AND verse = 1;

-- 출애굽기 20장: 십계명
UPDATE bible_verses SET
    chapter_title = '십계명',
    chapter_summary = '하나님께서 시내산에서 십계명을 선포하십니다. 첫째부터 넷째 계명은 하나님과의 관계에 대한 것이고, 다섯째부터 열째 계명은 인간관계에 대한 것입니다. 백성들이 두려워하자 모세가 중보자 역할을 합니다.',
    chapter_themes = '["십계명", "하나님과의 관계", "인간관계", "모세의 중보", "도덕적 기초"]',
    chapter_context = '인류 도덕과 법의 기초가 되는 십계명이 주어집니다. 하나님 중심의 신앙과 이웃 사랑의 균형을 보여줍니다.',
    chapter_application = '하나님을 사랑하고 이웃을 사랑하는 것이 모든 계명의 요약이며, 이는 그리스도인의 기본적인 삶의 원리입니다.'
WHERE book_id = 'ex' AND chapter = 20 AND verse = 1;

-- 출애굽기 21장: 종과 상해에 관한 법
UPDATE bible_verses SET
    chapter_title = '종과 상해에 관한 법',
    chapter_summary = '히브리 종의 해방에 관한 법과 상해를 입힌 자에 대한 보복법이 주어집니다. "눈에는 눈, 이에는 이"라는 동해보복법의 원칙이 제시되어 과도한 복수를 방지합니다.',
    chapter_themes = '["종의 해방", "동해보복법", "인간의 존엄성", "공정한 재판", "사회 정의"]',
    chapter_context = '고대 근동 지역의 법전들과 비교할 때 상당히 인도적인 법들입니다. 특히 종의 인권 보호가 두드러집니다.',
    chapter_application = '모든 인간은 하나님의 형상으로 지음받았으므로 존중받아야 하며, 정의는 공평하게 시행되어야 합니다.'
WHERE book_id = 'ex' AND chapter = 21 AND verse = 1;

-- 출애굽기 22장: 재산과 도덕에 관한 법
UPDATE bible_verses SET
    chapter_title = '재산과 도덕에 관한 법',
    chapter_summary = '도둑질, 손해 배상, 예금과 차용에 관한 법과 처녀와의 관계, 무당과 수간, 이방 신 제사 등 도덕적 범죄에 대한 법이 주어집니다. 고아와 과부, 나그네에 대한 보호법도 포함됩니다.',
    chapter_themes = '["재산권 보호", "도덕적 순결", "사회적 약자 보호", "정의로운 사회", "공동체 윤리"]',
    chapter_context = '개인의 재산권과 사회적 약자 보호를 균형있게 다루는 진보적인 법체계를 보여줍니다.',
    chapter_application = '재물에 대한 정직함과 사회적 약자에 대한 배려는 하나님 백성의 기본 덕목이며, 공동체의 건강함을 위해 필수적입니다.'
WHERE book_id = 'ex' AND chapter = 22 AND verse = 1;

-- 출애굽기 23장: 공의와 절기에 관한 법
UPDATE bible_verses SET
    chapter_title = '공의와 절기에 관한 법',
    chapter_summary = '거짓 증거 금지, 공정한 재판, 원수에 대한 선행 등 공의에 관한 법과 안식년, 안식일, 그리고 세 절기(무교절, 맥추절, 수장절)에 대한 규례가 주어집니다.',
    chapter_themes = '["공정한 재판", "원수 사랑", "안식년과 안식일", "세 절기", "약속 땅 정착 예언"]',
    chapter_context = '사회 정의와 종교적 절기를 통해 하나님 중심의 공동체가 어떤 모습이어야 하는지 제시합니다.',
    chapter_application = '원수까지도 사랑하는 것이 하나님의 뜻이며, 정기적인 안식과 절기를 통해 하나님과의 관계를 지속해야 합니다.'
WHERE book_id = 'ex' AND chapter = 23 AND verse = 1;

-- 출애굽기 24장: 언약의 체결
UPDATE bible_verses SET
    chapter_title = '언약의 체결',
    chapter_summary = '모세가 하나님의 모든 말씀을 백성에게 전하고, 백성들이 순종하겠다고 응답합니다. 모세가 피로 언약을 확증하고 시내산에 올라가 40일 동안 머물며 하나님의 영광을 봅니다.',
    chapter_themes = '["언약 체결", "피로 확증", "백성의 서약", "모세의 산상 체류", "하나님의 영광"]',
    chapter_context = '구약의 가장 중요한 언약 체결 의식입니다. 피로 확증하는 언약은 그리스도의 피 언약을 예표합니다.',
    chapter_application = '하나님과의 언약은 피로 확증되는 엄숙한 것이며, 우리도 그리스도의 피로 맺어진 새 언약에 신실해야 합니다.'
WHERE book_id = 'ex' AND chapter = 24 AND verse = 1;

-- 출애굽기 25장: 성막 제작 명령 시작
UPDATE bible_verses SET
    chapter_title = '성막 제작 명령 시작',
    chapter_summary = '하나님께서 모세에게 성막을 지으라 명하시며 백성들로부터 예물을 받으라 하십니다. 지성소에 들어갈 증거궤(언약궤)와 그 위의 속죄소, 그룹들에 대한 자세한 제작 지침을 주십니다.',
    chapter_themes = '["성막 제작 명령", "자원 예물", "언약궤", "속죄소", "하나님의 임재"]',
    chapter_context = '하나님께서 인간과 함께 거하시기 위한 성막 제작이 시작됩니다. 모든 규격과 재료가 하나님의 지시에 따라 정해집니다.',
    chapter_application = '하나님은 우리와 함께 거하시기를 원하시며, 예배와 봉사는 하나님의 뜻에 따라 자원하는 마음으로 드려져야 합니다.'
WHERE book_id = 'ex' AND chapter = 25 AND verse = 1;

-- 출애굽기 26장: 성막의 구조
UPDATE bible_verses SET
    chapter_title = '성막의 구조',
    chapter_summary = '성막의 휘장들과 널판들, 기둥들에 대한 자세한 제작 지침이 주어집니다. 지성소와 성소를 구분하는 휘장과 성막의 전체적인 구조가 설명됩니다.',
    chapter_themes = '["성막 휘장", "널판과 기둥", "지성소와 성소 구분", "정교한 설계", "하나님의 거룩함"]',
    chapter_context = '성막의 물리적 구조를 통해 하나님의 거룩함과 인간이 하나님께 나아가는 방법을 보여줍니다.',
    chapter_application = '하나님은 거룩하신 분이시므로 함부로 가까이 할 수 없으며, 정해진 방법을 통해서만 하나님께 나아갈 수 있습니다.'
WHERE book_id = 'ex' AND chapter = 26 AND verse = 1;

-- 출애굽기 27장: 제단과 성막 뜰
UPDATE bible_verses SET
    chapter_title = '제단과 성막 뜰',
    chapter_summary = '번제단의 제작법과 성막 뜰의 휘장들, 기둥들에 대한 지침이 주어집니다. 또한 등불을 켜기 위한 순수한 감람기름을 가져오라는 명령도 있습니다.',
    chapter_themes = '["번제단", "성막 뜰", "순수한 감람기름", "지속적인 등불", "제사 제도"]',
    chapter_context = '번제단은 죄 사함을 위한 제사의 중심이며, 지속적으로 켜지는 등불은 하나님의 지속적인 임재를 상징합니다.',
    chapter_application = '하나님께 나아가기 위해서는 제사(예수 그리스도의 십자가)가 필요하며, 하나님의 빛 가운데 지속적으로 거해야 합니다.'
WHERE book_id = 'ex' AND chapter = 27 AND verse = 1;

-- 출애굽기 28장: 제사장의 의복
UPDATE bible_verses SET
    chapter_title = '제사장의 의복',
    chapter_summary = '아론과 그 아들들을 제사장으로 세우고 그들이 입을 거룩한 의복들에 대한 자세한 지침이 주어집니다. 에봇, 흉패, 관, 속옷 등 각각의 의미와 제작법이 설명됩니다.',
    chapter_themes = '["제사장 제도", "거룩한 의복", "에봇과 흉패", "우림과 둠밍", "하나님과 백성의 중보"]',
    chapter_context = '제사장은 하나님과 백성 사이의 중보자 역할을 하며, 각 의복은 그리스도의 대제사장직을 예표합니다.',
    chapter_application = '예수 그리스도는 우리의 영원한 대제사장이시며, 모든 성도는 왕 같은 제사장으로서 중보의 사명을 감당해야 합니다.'
WHERE book_id = 'ex' AND chapter = 28 AND verse = 1;

-- 출애굽기 29장: 제사장 위임식
UPDATE bible_verses SET
    chapter_title = '제사장 위임식',
    chapter_summary = '아론과 그 아들들을 제사장으로 위임하는 의식에 대한 자세한 절차가 주어집니다. 관유로 기름 부음, 각종 제사 드림, 7일간의 위임 기간 등이 포함됩니다.',
    chapter_themes = '["제사장 위임식", "기름 부음", "각종 제사", "7일간의 성별", "하나님께 드리는 헌신"]',
    chapter_context = '제사장직은 하나님의 부르심과 기름 부음으로 시작되며, 엄숙한 의식을 통해 확립됩니다.',
    chapter_application = '하나님의 사역자가 되는 것은 특별한 부르심이며, 온전한 헌신과 성별이 필요합니다.'
WHERE book_id = 'ex' AND chapter = 29 AND verse = 1;

-- 출애굽기 30장: 분향단과 성막세
UPDATE bible_verses SET
    chapter_title = '분향단과 성막세',
    chapter_summary = '분향단 제작법과 향을 피우는 규례, 물두멍 제작, 관유와 향 제조법, 그리고 20세 이상 남자들이 드릴 성막세에 대한 지침이 주어집니다.',
    chapter_themes = '["분향단", "향의 규례", "물두멍", "관유와 향", "성막세"]',
    chapter_context = '분향은 성도의 기도를 상징하며, 성막세는 모든 백성이 성막 유지에 참여함을 보여줍니다.',
    chapter_application = '기도는 하나님께 상달되는 향과 같으며, 하나님의 집을 위한 헌신에 모든 성도가 참여해야 합니다.'
WHERE book_id = 'ex' AND chapter = 30 AND verse = 1;

-- 출애굽기 31장: 브살렐과 오홀리압의 부르심
UPDATE bible_verses SET
    chapter_title = '브살렐과 오홀리압의 부르심',
    chapter_summary = '하나님께서 브살렐과 오홀리압을 성막 제작의 기능인으로 부르시고 지혜와 총명을 주십니다. 또한 안식일 규례를 재확인하시며 모세에게 두 돌판에 기록된 증거판을 주십니다.',
    chapter_themes = '["브살렐과 오홀리압", "하나님이 주신 기능", "안식일 준수", "증거판", "하나님의 손가락으로 쓰심"]',
    chapter_context = '하나님의 사역에는 다양한 은사와 기능이 필요하며, 안식일은 하나님과 백성 사이의 표징임이 강조됩니다.',
    chapter_application = '하나님은 각자에게 다른 은사를 주시므로 각자의 달란트로 하나님 나라를 섬겨야 하며, 안식일을 통해 하나님과의 관계를 새롭게 해야 합니다.'
WHERE book_id = 'ex' AND chapter = 31 AND verse = 1;

-- 출애굽기 32장: 금송아지 우상 사건
UPDATE bible_verses SET
    chapter_title = '금송아지 우상 사건',
    chapter_summary = '모세가 산에 오래 머물자 백성들이 아론에게 금송아지를 만들어 달라고 요구합니다. 아론이 금송아지를 만들어 이것이 이집트에서 인도한 신이라고 하자, 하나님이 진노하시고 모세가 중보기도 후 산에서 내려와 돌판을 깨뜨립니다.',
    chapter_themes = '["금송아지 우상", "백성의 배교", "아론의 타협", "하나님의 진노", "모세의 중보기도"]',
    chapter_context = '언약 체결 직후 일어난 배교 사건으로, 인간의 연약함과 우상 숭배의 위험성을 보여줍니다.',
    chapter_application = '눈에 보이지 않는 하나님을 기다리는 것은 어렵지만, 그 어떤 것도 하나님을 대신할 수 없으며, 지도자는 백성의 잘못된 요구에 타협해서는 안됩니다.'
WHERE book_id = 'ex' AND chapter = 32 AND verse = 1;

-- 출애굽기 33장: 하나님의 영광을 구하는 모세
UPDATE bible_verses SET
    chapter_title = '하나님의 영광을 구하는 모세',
    chapter_summary = '하나님께서 금송아지 사건으로 인해 친히 함께 가지 않겠다고 하시자, 모세가 간절히 기도합니다. 모세는 하나님의 영광을 보여달라고 구하고, 하나님께서 당신의 선하심을 보여주시되 얼굴은 보지 못하게 하십니다.',
    chapter_themes = '["하나님의 임재 철회", "모세의 간구", "하나님의 영광", "하나님의 선하심", "얼굴을 마주 대하여"]',
    chapter_context = '죄로 인해 거룩하신 하나님이 함께 하실 수 없음을 보여주지만, 모세의 중보로 관계가 회복됩니다.',
    chapter_application = '죄는 하나님과의 관계를 막지만, 진실한 회개와 중보기도를 통해 관계가 회복될 수 있습니다.'
WHERE book_id = 'ex' AND chapter = 33 AND verse = 1;

-- 출애굽기 34장: 언약의 갱신
UPDATE bible_verses SET
    chapter_title = '언약의 갱신',
    chapter_summary = '하나님께서 새 돌판을 만들어 오라 하시고 다시 십계명을 새기시며, 하나님의 이름의 의미를 선포하십니다. 모세가 40일간 산에 머물며 언약을 갱신하고 내려올 때 얼굴에서 광채가 나서 수건으로 가립니다.',
    chapter_themes = '["언약 갱신", "하나님의 이름 선포", "자비하고 은혜로우신 하나님", "모세 얼굴의 광채", "새 돌판"]',
    chapter_context = '하나님의 용서와 긍휼로 깨어진 언약이 회복됩니다. 하나님의 성품에 대한 중요한 계시가 주어집니다.',
    chapter_application = '하나님은 자비롭고 은혜로우시며 용서하시는 분이므로, 우리의 실패에도 불구하고 새로운 시작을 주십니다.'
WHERE book_id = 'ex' AND chapter = 34 AND verse = 1;

-- 출애굽기 35장: 성막 건축 시작
UPDATE bible_verses SET
    chapter_title = '성막 건축 시작',
    chapter_summary = '모세가 백성들에게 성막 건축을 위한 예물을 자원하는 마음으로 가져오라 하고, 브살렐과 오홀리압을 기능인으로 소개합니다. 백성들이 자원하여 풍성한 예물을 가져옵니다.',
    chapter_themes = '["자원하는 예물", "브살렐과 오홀리압", "백성의 자발적 참여", "성막 건축 시작", "기쁜 마음의 헌신"]',
    chapter_context = '금송아지 사건 이후 백성들의 회개와 헌신이 나타납니다. 자원하는 마음의 예물이 강조됩니다.',
    chapter_application = '하나님께 드리는 모든 것은 자원하는 마음과 기쁨으로 드려져야 하며, 하나님의 사역에 모든 백성이 각자의 능력에 따라 참여해야 합니다.'
WHERE book_id = 'ex' AND chapter = 35 AND verse = 1;

-- 출애굽기 36장: 성막 제작 과정
UPDATE bible_verses SET
    chapter_title = '성막 제작 과정',
    chapter_summary = '백성들이 너무 많은 예물을 가져와서 모세가 그만 가져오라고 공포할 정도가 됩니다. 브살렐과 기능공들이 성막의 휘장들과 널판들을 정교하게 제작합니다.',
    chapter_themes = '["풍성한 예물", "제작 중단 공포", "정교한 기술", "하나님이 주신 지혜", "공동체의 헌신"]',
    chapter_context = '백성들의 자발적이고 풍성한 헌신과 하나님이 주신 기술로 성막이 제작됩니다.',
    chapter_application = '하나님의 사역에는 풍성한 자원이 필요하며, 하나님은 당신의 사역을 위해 필요한 모든 것을 공급하십니다.'
WHERE book_id = 'ex' AND chapter = 36 AND verse = 1;

-- 출애굽기 37장: 성막 기구들 제작
UPDATE bible_verses SET
    chapter_title = '성막 기구들 제작',
    chapter_summary = '브살렐이 언약궤, 속죄소, 상, 등대, 분향단 등 성막의 모든 기구들을 하나님의 지시대로 정교하게 제작합니다. 모든 것이 순금과 조각목으로 만들어집니다.',
    chapter_themes = '["언약궤 제작", "성막 기구들", "정교한 세공", "순금 사용", "하나님의 명령 준수"]',
    chapter_context = '성막의 모든 기구들이 하나님의 명령에 정확히 따라 제작되어 하나님의 임재를 위한 준비가 완료됩니다.',
    chapter_application = '하나님의 일은 하나님의 방법대로 행해져야 하며, 최선의 재료와 정성으로 하나님께 드려져야 합니다.'
WHERE book_id = 'ex' AND chapter = 37 AND verse = 1;

-- 출애굽기 38장: 제단과 뜰 완성
UPDATE bible_verses SET
    chapter_title = '제단과 뜰 완성',
    chapter_summary = '번제단과 물두멍, 성막 뜰의 휘장들이 완성되고, 성막 제작에 사용된 모든 재료의 총계가 기록됩니다. 레위인들이 모세의 명령에 따라 이다말의 수하에서 계산합니다.',
    chapter_themes = '["번제단과 물두멍", "성막 뜰 완성", "재료 총계", "투명한 회계", "레위인의 봉사"]',
    chapter_context = '성막 건축의 투명한 회계 처리와 완성 과정을 보여줍니다. 모든 과정이 질서 정연하게 진행됩니다.',
    chapter_application = '하나님의 사역에는 투명성과 책임성이 있어야 하며, 모든 것이 질서있게 행해져야 합니다.'
WHERE book_id = 'ex' AND chapter = 38 AND verse = 1;

-- 출애굽기 39장: 제사장 의복 완성
UPDATE bible_verses SET
    chapter_title = '제사장 의복 완성',
    chapter_summary = '아론과 그 아들들의 거룩한 의복들이 모두 완성됩니다. 에봇, 흉패, 관, 속옷 등이 하나님의 명령대로 정교하게 제작되어 모세에게 가져옵니다.',
    chapter_themes = '["제사장 의복 완성", "하나님의 명령 준수", "정교한 제작", "모세의 검수", "거룩한 봉사 준비"]',
    chapter_context = '제사장들의 거룩한 봉사를 위한 모든 준비가 완료되어 성막에서의 예배가 시작될 수 있게 됩니다.',
    chapter_application = '하나님을 섬기는 일에는 정성스런 준비와 거룩한 마음가짐이 필요하며, 모든 것이 하나님의 뜻에 맞게 행해져야 합니다.'
WHERE book_id = 'ex' AND chapter = 39 AND verse = 1;

-- 출애굽기 40장: 성막 완성과 하나님의 영광
UPDATE bible_verses SET
    chapter_title = '성막 완성과 하나님의 영광',
    chapter_summary = '하나님의 명령에 따라 성막이 세워지고 모든 기구들이 제자리에 놓입니다. 아론과 그 아들들이 기름 부음을 받고, 성막이 완성되자 하나님의 영광이 성막에 가득하여 모세도 들어가지 못합니다.',
    chapter_themes = '["성막 완성", "하나님의 영광", "구름과 불", "하나님의 임재", "이스라엘의 인도"]',
    chapter_context = '출애굽기의 절정으로, 하나님께서 당신의 백성과 함께 거하시기 위해 성막에 임재하십니다.',
    chapter_application = '하나님은 당신의 백성과 함께 거하시기를 원하시며, 우리 안에 성령으로 거하시는 하나님을 인정하고 순종해야 합니다.'
WHERE book_id = 'ex' AND chapter = 40 AND verse = 1;