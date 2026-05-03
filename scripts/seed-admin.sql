DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.utilisateurs WHERE email = 'admin@exemple.com'
    ) THEN
        INSERT INTO public.utilisateurs (nom, prenom, email, mot_de_passe, role)
        VALUES (
            'Admin',
            'System',
            'admin@exemple.com',
            '$2a$06$3ZyP8Rnwqn6Sk/VakQkIMuUsme2XbHPna/wK9ZKa3HUam8GQfZCAm',
            'admin'
        );
        RAISE NOTICE '✅ Admin user created';
    ELSE
        RAISE NOTICE 'ℹ️ Admin user already exists';
    END IF;
END $$;