-- NOT_COUNTED (25): admin-only terminal status; excluded from monthly intro limits like ADMIN_REJECTED.
INSERT INTO public.introduction_status (id, name, isfinal)
VALUES (25, 'NOT_COUNTED', true)
ON CONFLICT (id) DO NOTHING;
