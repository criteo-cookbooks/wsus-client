if defined?(ChefSpec)
  ChefSpec.define_matcher :wsus_client_update
  def download_wsus_client_update(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:wsus_client_update, :download, resource)
  end

  def install_wsus_client_update(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:wsus_client_update, :install, resource)
  end
end
