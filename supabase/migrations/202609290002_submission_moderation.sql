-- Moderasi atomik: member tidak pernah dapat menerbitkan produk sendiri.
create or replace function public.moderate_submission(target_submission uuid, target_decision public.review_decision, review_notes text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare s public.submissions%rowtype; new_product_id uuid; new_version_id uuid; generated_slug text;
begin
  if not public.is_admin() then raise exception 'FORBIDDEN'; end if;
  if nullif(trim(review_notes), '') is null then raise exception 'NOTES_REQUIRED'; end if;
  select * into s from public.submissions where id = target_submission and status = 'PENDING_REVIEW' for update;
  if s.id is null then raise exception 'SUBMISSION_NOT_PENDING'; end if;
  insert into public.submission_reviews(submission_id, reviewer_id, decision, notes, snapshot)
  values(s.id, auth.uid(), target_decision, review_notes, to_jsonb(s));
  if target_decision = 'APPROVED' then
    generated_slug := lower(regexp_replace(s.name, '[^a-zA-Z0-9]+', '-', 'g')) || '-' || substr(s.id::text, 1, 8);
    insert into public.products(game_id, category_id, created_by, source_submission_id, name, slug, description, tutorial, creator_name, source_url, screenshot_urls, type, price, status, published_at)
    values(s.game_id, s.category_id, auth.uid(), s.id, s.name, generated_slug, s.description, s.tutorial, s.creator_name, s.source_url, s.screenshot_urls, 'FREE', 0, 'PUBLISHED', now()) returning id into new_product_id;
    insert into public.product_versions(product_id, version, is_current) values(new_product_id, s.mod_version, true) returning id into new_version_id;
    insert into public.download_links(product_version_id, provider, external_url, status) values(new_version_id, 'external', s.download_url, 'ACTIVE');
    update public.submissions set status = 'APPROVED', product_id = new_product_id, updated_at = now() where id = s.id;
  else
    update public.submissions set status = target_decision::text::public.submission_status, updated_at = now() where id = s.id;
  end if;
  insert into public.audit_logs(actor_id, action, entity_type, entity_id, metadata)
  values(auth.uid(), 'SUBMISSION_' || target_decision::text, 'submission', s.id, jsonb_build_object('notes', review_notes));
  return new_product_id;
end; $$;
revoke all on function public.moderate_submission(uuid, public.review_decision, text) from public;
grant execute on function public.moderate_submission(uuid, public.review_decision, text) to authenticated;
