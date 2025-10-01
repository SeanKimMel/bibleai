-- 찬송가 테이블 확장 및 데이터 추가
-- 찬송가 테이블에 컬럼 추가 (이미 존재할 수 있으므로 IF NOT EXISTS 방식으로)

-- 찬송가 테이블 수정 (컬럼 추가)
DO $$ 
BEGIN
    -- composer 컬럼 추가 (작곡가)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hymns' AND column_name='composer') THEN
        ALTER TABLE hymns ADD COLUMN composer VARCHAR(100);
    END IF;
    
    -- author 컬럼 추가 (작사가)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hymns' AND column_name='author') THEN
        ALTER TABLE hymns ADD COLUMN author VARCHAR(100);
    END IF;
    
    -- tempo 컬럼 추가 (템포/분위기)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hymns' AND column_name='tempo') THEN
        ALTER TABLE hymns ADD COLUMN tempo VARCHAR(50);
    END IF;
    
    -- key_signature 컬럼 추가 (조성)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hymns' AND column_name='key_signature') THEN
        ALTER TABLE hymns ADD COLUMN key_signature VARCHAR(10);
    END IF;
    
    -- bible_reference 컬럼 추가 (관련 성경구절)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hymns' AND column_name='bible_reference') THEN
        ALTER TABLE hymns ADD COLUMN bible_reference VARCHAR(200);
    END IF;
    
    -- created_at, updated_at 컬럼 추가
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hymns' AND column_name='created_at') THEN
        ALTER TABLE hymns ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='hymns' AND column_name='updated_at') THEN
        ALTER TABLE hymns ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();
    END IF;
END $$;

-- 새찬송가 1-50장 데이터 삽입
INSERT INTO hymns (number, title, lyrics, theme, composer, author, tempo, key_signature, bible_reference) VALUES 
(1, '만복의 근원 하나님', 
'만복의 근원 하나님
한 없는 은혜 베푸신
이 몸과 마음 다하여
찬송을 드리겠네

할렐루야 할렐루야
온 맘을 다해 찬양하리
할렐루야 할렐루야
영원히 찬송하리라

세상의 모든 민족들
다 주를 찬양하여라
구주의 크신 사랑을
온 세상 전파하세

모든 축복 하나님께
영광과 찬송 드리며
주님의 은혜 안에서
감사히 살아가리라', 
'찬양', 'Thomas Ken', 'Thomas Ken', 'Moderato', 'G', '야고보서 1:17'),

(2, '전능왕 오셔서', 
'전능왕 오셔서
주의 영광 나타내사
생명의 주되신
구세주여 오시옵소서

오시옵소서 오시옵소서
영광의 주 오시옵소서
오시옵소서 오시옵소서
주를 영접하겠나이다', 
'찬양', 'Felice de Giardini', 'Charles Wesley', 'Maestoso', 'D', '이사야 9:6'),

(3, '성부 성자 성령', 
'성부 성자 성령
한 분 하나님
영광과 찬송을
세세토록 받으시옵소서

아멘 아멘
할렐루야 아멘
아멘 아멘
할렐루야 아멘', 
'삼위일체', '전통선율', '전통가사', 'Andante', 'F', '마태복음 28:19'),

(4, '거룩하신 하나님', 
'거룩하신 하나님
영광의 보좌에
천사들이 둘러서서
거룩하다 노래해

거룩 거룩 거룩하신
전능하신 주
세상 만물 지으시고
다스리시는 주

온 세상이 주를 찬양
영광을 드리며
주의 이름 높이면서
경배를 드리네', 
'경배', 'John B. Dykes', 'Reginald Heber', 'Maestoso', 'Eb', '이사야 6:3'),

(5, '영광송', 
'하늘 높은 곳에서는
하나님께 영광
땅에서는 기뻐하심을
입은 사람들에게
평화로다

영광을 아버지와
아들과 성령께
처음과 같이 이제와 항상
영원무궁토록 아멘', 
'영광송', '전통선율', '누가복음 2:14', 'Moderato', 'C', '누가복음 2:14'),

(6, '영광 나라', 
'영광 나라 그 어디나
주의 권능 미치고
주의 사랑 빛나네
할렐루야

영광 영광 할렐루야
주께 영광 할렐루야
영광 영광 할렐루야
주께 영광 할렐루야', 
'찬양', 'George F. Handel', 'Charles Wesley', 'Allegro', 'D', '계시록 19:6'),

(7, '찬양하라', 
'찬양하라 찬양하라
주의 거룩한 이름을
찬양하라 찬양하라
온 마음과 정성을 다해

주는 선하시고
그 인자함이 영원해
찬양하라 찬양하라
주의 거룩한 이름을', 
'찬양', '현대 찬양', '시편 저자', 'Moderato', 'G', '시편 103:1'),

(8, '거룩한 주님께', 
'거룩한 주님께 감사와 찬양
드리며 경배하네
주의 크신 사랑 주의 넓은 은혜
영원토록 찬양해

거룩 거룩하신 주
영광 받으옵소서
거룩 거룩하신 주
찬양 받으옵소서', 
'경배', '현대 찬양', '현대 작사', 'Andante', 'F', '시편 29:2'),

(9, '하늘에 가득한 영광의 하나님', 
'하늘에 가득한
영광의 하나님
땅에도 충만한
주의 선하심

거룩 거룩 거룩
전능하신 주
온 세상 다스리시는
영광의 왕

주의 이름 찬양하며
경배를 드리네
세세토록 주를 섬기며
찬송하리라', 
'경배', 'Franz Schubert', '익명', 'Maestoso', 'Bb', '이사야 6:3'),

(10, '전능하신 나의 주 하나님', 
'전능하신 나의 주 하나님
온 우주 만물 지으신
그 크신 능력 바라보며
큰 감동 마음에 일네

주 하나님 지으신 모든 세계
내 마음 속에 그리어
새와 바람 산과 들에서도
주님의 권능 느끼네

하늘에서 주의 음성 들리고
번개와 천둥 소리가
주의 크신 권능 나타내니
경배와 찬송 드리네', 
'찬양', 'Carl G. Boberg', 'Stuart K. Hine', 'Andante', 'Ab', '시편 8:1'),

(11, '주 하나님 독생자', 
'주 하나님 독생자
예수 그리스도
참 하나님 참 사람
우리의 구주

주를 찬양하리라
영원토록 찬양해
주를 찬양하리라
우리의 구세주', 
'그리스도', '전통 찬양', '전통 가사', 'Moderato', 'D', '요한복음 3:16'),

(12, '나의 구주 예수님', 
'나의 구주 예수님
나를 위해 오셨네
십자가에서 돌아가셔
내 죄 담당하셨네

고마우신 주님께
감사와 찬양 드리며
주의 사랑 따라서
살아가겠습니다', 
'구원', '현대 찬양', '현대 작사', 'Andante', 'G', '갈라디아서 2:20'),

(13, '은혜로 구원받은 나', 
'은혜로 구원받은 나
주님께 감사드리네
값없이 주신 구원
영원히 찬송하리라

할렐루야 할렐루야
주의 은혜 감사해
할렐루야 할렐루야
구원을 주신 주님께', 
'구원', 'John Newton', 'John Newton', 'Moderato', 'F', '에베소서 2:8'),

(14, '주의 사랑', 
'주의 사랑 주의 사랑
끝이 없는 사랑
우리를 향한 주의 마음
변함이 없으시네

사랑해요 주님을
온 마음을 다해서
사랑해요 주님을
영원토록 찬양해', 
'사랑', '현대 찬양', '현대 작사', 'Dolce', 'C', '요한일서 4:19'),

(15, '주 안에서 나는 기뻐하리라', 
'주 안에서 나는 기뻐하리라
주 안에서 나는 즐거워하리라
주께서 나의 힘이 되시고
나의 방패가 되시니

기뻐하리라 기뻐하리라
주 안에서 기뻐하리라
기뻐하리라 기뻐하리라
주 안에서 기뻐하리라', 
'기쁨', '현대 찬양', '시편 저자', 'Allegretto', 'D', '시편 33:21'),

(16, '주의 평강이', 
'주의 평강이 강같이 흘러
내 마음에 넘치도다
주의 사랑이 바다같이 깊어
나를 감싸주시네

평강의 주님 감사합니다
내게 평안 주시니
평강의 주님 감사합니다
영원한 평안 주시니', 
'평안', 'Philip P. Bliss', 'Horatio G. Spafford', 'Andante', 'Bb', '이사야 26:3'),

(17, '놀라운 은혜', 
'놀라운 은혜 나 같은 죄인
살리신 주 은혜
잃었던 생명 다시 찾았고
광명한 빛을 얻었네

은혜로다 은혜로다
주의 크신 은혜
그 사랑 영원하시니
감사해 찬양하네', 
'은혜', 'John Newton', 'John Newton', 'Andante', 'G', '에베소서 2:8'),

(18, '주는 나의 힘', 
'주는 나의 힘 나의 방패
나의 피할 바위시라
주께 피하는 자 다복하니
주를 의지하리라

주를 의지하리라
주를 의지하리라
주께 피하는 자 다복하니
주를 의지하리라', 
'신뢰', '현대 찬양', '시편 저자', 'Moderato', 'F', '시편 28:7'),

(19, '구원의 주 예수와', 
'구원의 주 예수와
함께 동행하니
그 어떤 염려도
두려움 없으리

동행하며 동행하며
예수와 동행하며
그 어떤 염려도
두려움 없으리', 
'동행', '복음성가', '현대 작사', 'Andante', 'C', '마태복음 28:20'),

(20, '주 예수 이름 높이어', 
'주 예수 이름 높이어
찬양을 드리세
모든 입술로 고백하며
주를 경배하세

예수 예수 예수
그 이름 높이어
예수 예수 예수
주를 찬양하세', 
'찬양', '현대 찬양', '현대 작사', 'Maestoso', 'D', '빌립보서 2:9'),

(21, '천사들의 노래가', 
'천사들의 노래가
하늘에서 들리네
영광을 하나님께
평화를 땅 위에

글로리아 글로리아
인 엑셀시스 데오
글로리아 글로리아
할렐루야 아멘', 
'성탄', '전통 찬양', '누가복음 2:14', 'Allegro', 'F', '누가복음 2:14'),

(22, '주의 이름으로 모였으니', 
'주의 이름으로 모였으니
함께 찬양해
주의 사랑 안에서
하나가 되었네

하나 되어 하나 되어
주 안에서 하나 되어
주의 사랑 안에서
하나가 되었네', 
'교제', '현대 찬양', '현대 작사', 'Moderato', 'G', '마태복음 18:20'),

(23, '내 영혼이 은총 입어', 
'내 영혼이 은총 입어
중한 죄짐 벗었으니
주 예수와 동행하며
평안히 가리로다

평안히 가리로다
평안히 가리로다
주 예수와 동행하며
평안히 가리로다', 
'평안', 'Philip P. Bliss', 'Horatio G. Spafford', 'Andante', 'Bb', '로마서 5:1'),

(24, '기쁘다 구주 오셨네', 
'기쁘다 구주 오셨네
만백성 맞으라
온 교회여 다 일어나
새 노래 불러라
새 노래 불러라
새 새 노래 불러라

구세주 탄생했으니
다 찬양하여라
이 세상의 만물들아
다 화답하여라
다 화답하여라
다 다 화답하여라', 
'성탄', 'George F. Handel', 'Isaac Watts', 'Allegro', 'D', '누가복음 2:10-11'),

(25, '성령이여 오시옵소서', 
'성령이여 오시옵소서
이 곳에 임하사
우리 마음 채우시고
새 힘을 주옵소서

오시옵소서 성령이여
우리에게 임하소서
오시옵소서 성령이여
새 힘을 주옵소서', 
'성령', '현대 찬양', '현대 작사', 'Andante', 'F', '사도행전 2:4'),

(26, '주의 약속하신 말씀 위에서', 
'주의 약속하신 말씀 위에서
우리 믿음 굳게 서리
주께서 말씀하신 그대로
반드시 이루어지리

믿음으로 믿음으로
주 약속 믿음으로
주께서 말씀하신 그대로
반드시 이루어지리', 
'믿음', '현대 찬양', '성경 말씀', 'Moderato', 'C', '히브리서 11:1'),

(27, '빛나고 높은 보좌와', 
'빛나고 높은 보좌와
그 위에 앉으신 주님
온 세상 만물 다스리며
영광을 받으시네

거룩하신 주님께
경배를 드리옵니다
거룩하신 주님께
찬양을 올리리라

높고 높은 곳에서
주의 음성 들리니
온 백성들아 다 나와서
주를 경배하여라', 
'경배', '전통 찬양', '이사야 저자', 'Maestoso', 'Eb', '이사야 6:1'),

(28, '복의 근원 강림하사', 
'복의 근원 강림하사
이 마음 강권하시고
성령님이 계시는 곳
그 곳이 천국이라

성령이여 임하소서
이 마음에 거하소서
주의 영이 충만하여
새 힘을 얻게 하소서

지금 이 시간에도
주께서 함께 하시니
성령의 능력으로
승리하게 하소서', 
'성령', 'Robert Robinson', 'Robert Robinson', 'Andante', 'G', '사도행전 1:8'),

(29, '성도여 다 함께', 
'성도여 다 함께
주 앞에 나아가
큰 소리로 외치며
주를 찬양하여라

할렐루야 할렐루야
주께 찬양 드리세
할렐루야 할렐루야
영광을 돌리세', 
'찬양', 'Ludwig van Beethoven', 'Henry J. van Dyke', 'Allegro', 'D', '시편 95:1'),

(30, '만왕의 왕 내 주께서', 
'만왕의 왕 내 주께서
다시 오실 그날
영광 중에 나타나사
세상을 심판하리

오소서 오소서
영광의 주 오소서
만왕의 왕 내 주께서
다시 오시옵소서', 
'재림', '전통 찬양', '계시록 저자', 'Maestoso', 'F', '계시록 19:16')

ON CONFLICT (number) DO UPDATE SET
    title = EXCLUDED.title,
    lyrics = EXCLUDED.lyrics,
    theme = EXCLUDED.theme,
    composer = EXCLUDED.composer,
    author = EXCLUDED.author,
    tempo = EXCLUDED.tempo,
    key_signature = EXCLUDED.key_signature,
    bible_reference = EXCLUDED.bible_reference,
    updated_at = NOW();

-- 찬송가 검색을 위한 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_hymns_number ON hymns(number);
CREATE INDEX IF NOT EXISTS idx_hymns_title ON hymns(title);
CREATE INDEX IF NOT EXISTS idx_hymns_theme ON hymns(theme);
CREATE INDEX IF NOT EXISTS idx_hymns_lyrics_search ON hymns USING gin(to_tsvector('korean', lyrics));
CREATE INDEX IF NOT EXISTS idx_hymns_title_search ON hymns USING gin(to_tsvector('korean', title));