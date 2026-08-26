require 'test_helper'

class FieldLockTest < ActiveSupport::TestCase

  test 'can add field locks to a model' do
    event = events(:one)

    assert_empty event.locked_fields
    event.locked_fields = [:title, :description]
    assert_equal 2, event.locked_fields.length

    assert_difference('FieldLock.count', 2) do
      event.save
    end

    assert_equal [:title, :description].sort, event.locked_fields.sort
    assert event.field_locked?(:title)
    assert event.field_locked?(:description)
    refute event.field_locked?(:url)
  end

  test 'does not add duplicate field locks' do
    event = events(:one)

    event.locked_fields = [:title, :description, :description]

    assert_difference('FieldLock.count', 2) do
      event.save
    end
  end

  test 'strips aliased fields' do
    event = events(:one)

    event.locked_fields = [:title, :node_ids]

    params = { event: { title: 'Something', description: 'Something else', node_names: ['One', 'Two'] } }.with_indifferent_access
    FieldLock.strip_locked_fields(params[:event], event.locked_fields)
    assert_equal({ description: 'Something else' }.with_indifferent_access, params[:event])

    provider = content_providers(:goblet)
    provider.locked_fields = [:image]

    provider_params = {
      content_provider: {
        image: 'uploaded-file',
        image_url: 'http://example.com/new-image.png',
        title: 'Kept title'
      }
    }.with_indifferent_access
    FieldLock.strip_locked_fields(provider_params[:content_provider], provider.locked_fields)
    assert_equal({ title: 'Kept title' }.with_indifferent_access, provider_params[:content_provider])
  end

  test 'automatic field locking config supports all and per-resource values' do
    with_settings(automatic_field_locking: true) do
      assert TeSS::Config.automatic_field_locking_enabled_for?(Material)
      assert TeSS::Config.automatic_field_locking_enabled_for?(Event)
      assert TeSS::Config.automatic_field_locking_enabled_for?(ContentProvider)
    end

    with_settings(automatic_field_locking: %w[materials events]) do
      assert TeSS::Config.automatic_field_locking_enabled_for?(Material)
      assert TeSS::Config.automatic_field_locking_enabled_for?(Event)
      refute TeSS::Config.automatic_field_locking_enabled_for?(ContentProvider)
    end

    with_settings(automatic_field_locking: %w[providers]) do
      assert TeSS::Config.automatic_field_locking_enabled_for?(ContentProvider)
      refute TeSS::Config.automatic_field_locking_enabled_for?(Material)
      refute TeSS::Config.automatic_field_locking_enabled_for?(Event)
    end

    with_settings(automatic_field_locking: %w[material event content_provider]) do
      refute TeSS::Config.automatic_field_locking_enabled_for?(Material)
      refute TeSS::Config.automatic_field_locking_enabled_for?(Event)
      refute TeSS::Config.automatic_field_locking_enabled_for?(ContentProvider)
    end
  end

  test 'can add field locks to content provider' do
    provider = content_providers(:provider_with_empty_image_url)

    assert_empty provider.locked_fields
    provider.locked_fields = [:title, :image]

    assert_difference('FieldLock.count', 2) do
      provider.save
    end

    assert_equal [:image, :title], provider.locked_fields.sort
    assert provider.field_locked?(:title)
    assert provider.field_locked?(:image)

  end

end
