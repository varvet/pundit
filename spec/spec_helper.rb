class SpecHelper
  def self.pundit_examples(base, scope_const)
    base.instance_eval do
      describe "specs" do
        let(:user) { double }
        let(:post) { scope_const::Post.new(user) }
        let(:comment) { scope_const::Comment.new }
        let(:article) { scope_const::Article.new }
        let(:controller) { double(:current_user => user, :params => { :action => "update" }).tap { |c| c.extend(Pundit) } }
        let(:artificial_blog) { scope_const::ArtificialBlog.new }
        let(:article_tag) { scope_const::ArticleTag.new }

        describe ".policy_scope" do
          it "returns an instantiated policy scope given a plain model class" do
            expect(Pundit.policy_scope(user, scope_const::Post)).to eq :published
          end

          it "returns an instantiated policy scope given an active model class" do
            expect(Pundit.policy_scope(user, scope_const::Comment)).to eq scope_const::Comment
          end

          it "returns nil if the given policy scope can't be found" do
            expect(Pundit.policy_scope(user, scope_const::Article)).to be_nil
          end
        end

        describe ".policy_scope!" do
          it "returns an instantiated policy scope given a plain model class" do
            expect(Pundit.policy_scope!(user, scope_const::Post)).to eq :published
          end

          it "returns an instantiated policy scope given an active model class" do
            expect(Pundit.policy_scope!(user, scope_const::Comment)).to eq scope_const::Comment
          end

          it "throws an exception if the given policy scope can't be found" do
            expect { Pundit.policy_scope!(user, scope_const::Article) }.to raise_error(Pundit::NotDefinedError)
          end

          it "throws an exception if the given policy scope can't be found" do
            expect { Pundit.policy_scope!(user, scope_const::ArticleTag) }.to raise_error(Pundit::NotDefinedError)
          end
        end

        describe ".policy" do
          it "returns an instantiated policy given a plain model instance" do
            policy = Pundit.policy(user, post)
            expect(policy.user).to eq user
            expect(policy.post).to eq post
          end

          it "returns an instantiated policy given an active model instance" do
            policy = Pundit.policy(user, comment)
            expect(policy.user).to eq user
            expect(policy.comment).to eq comment
          end

          it "returns an instantiated policy given a plain model class" do
            policy = Pundit.policy(user, scope_const::Post)
            expect(policy.user).to eq user
            expect(policy.post).to eq scope_const::Post
          end

          it "returns an instantiated policy given an active model class" do
            policy = Pundit.policy(user, scope_const::Comment)
            expect(policy.user).to eq user
            expect(policy.comment).to eq scope_const::Comment
          end

          it "returns nil if the given policy can't be found" do
            expect(Pundit.policy(user, article)).to be_nil
            expect(Pundit.policy(user, scope_const::Article)).to be_nil
          end

          describe "with .policy_class set on the model" do
            it "returns an instantiated policy given a plain model instance" do
              policy = Pundit.policy(user, artificial_blog)
              expect(policy.user).to eq user
              expect(policy.blog).to eq artificial_blog
            end

            it "returns an instantiated policy given a plain model class" do
              policy = Pundit.policy(user, scope_const::ArtificialBlog)
              expect(policy.user).to eq user
              expect(policy.blog).to eq scope_const::ArtificialBlog
            end

            it "returns an instantiated policy given a plain model instance providing an anonymous class" do
              policy = Pundit.policy(user, article_tag)
              expect(policy.user).to eq user
              expect(policy.tag).to eq article_tag
            end

            it "returns an instantiated policy given a plain model class providing an anonymous class" do
              policy = Pundit.policy(user, scope_const::ArticleTag)
              expect(policy.user).to eq user
              expect(policy.tag).to eq scope_const::ArticleTag
            end
          end
        end

        describe ".policy!" do
          it "returns an instantiated policy given a plain model instance" do
            policy = Pundit.policy!(user, post)
            expect(policy.user).to eq user
            expect(policy.post).to eq post
          end

          it "returns an instantiated policy given an active model instance" do
            policy = Pundit.policy!(user, comment)
            expect(policy.user).to eq user
            expect(policy.comment).to eq comment
          end

          it "returns an instantiated policy given a plain model class" do
            policy = Pundit.policy!(user, scope_const::Post)
            expect(policy.user).to eq user
            expect(policy.post).to eq scope_const::Post
          end

          it "returns an instantiated policy given an active model class" do
            policy = Pundit.policy!(user, scope_const::Comment)
            expect(policy.user).to eq user
            expect(policy.comment).to eq scope_const::Comment
          end

          it "throws an exception if the given policy can't be found" do
            expect { Pundit.policy!(user, article) }.to raise_error(Pundit::NotDefinedError)
            expect { Pundit.policy!(user, scope_const::Article) }.to raise_error(Pundit::NotDefinedError)
          end
        end

        describe "#verify_authorized" do
          it "does nothing when authorized" do
            controller.authorize(post)
            controller.verify_authorized
          end

          it "raises an exception when not authorized" do
            expect { controller.verify_authorized }.to raise_error(Pundit::NotAuthorizedError)
          end
        end

        describe "#verify_policy_scoped" do
          it "does nothing when policy_scope is used" do
            controller.policy_scope(scope_const::Post)
            controller.verify_policy_scoped
          end

          it "raises an exception when policy_scope is not used" do
            expect { controller.verify_policy_scoped }.to raise_error(Pundit::NotAuthorizedError)
          end
        end

        describe "#authorize" do
          it "infers the policy name and authorized based on it" do
            expect(controller.authorize(post)).to be_truthy
          end

          it "can be given a different permission to check" do
            expect(controller.authorize(post, :show?)).to be_truthy
            expect { controller.authorize(post, :destroy?) }.to raise_error(Pundit::NotAuthorizedError)
          end

          it "works with anonymous class policies" do
            expect(controller.authorize(article_tag, :show?)).to be_truthy
            expect { controller.authorize(article_tag, :destroy?) }.to raise_error(Pundit::NotAuthorizedError)
          end

          it "raises an error when the permission check fails" do
            expect { controller.authorize(scope_const::Post.new) }.to raise_error(Pundit::NotAuthorizedError)
          end

          it "raises an error with a query and action" do
            expect { controller.authorize(post, :destroy?) }.to raise_error do |error|
              expect(error.query).to eq :destroy?
              expect(error.record).to eq post
              expect(error.policy).to eq controller.policy(post)
            end
          end
        end

        describe "#pundit_user" do
          it 'returns the same thing as current_user' do
            expect(controller.pundit_user).to eq controller.current_user
          end
        end

        describe ".policy" do
          it "returns an instantiated policy" do
            policy = controller.policy(post)
            expect(policy.user).to eq user
            expect(policy.post).to eq post
          end

          it "throws an exception if the given policy can't be found" do
            expect { controller.policy(article) }.to raise_error(Pundit::NotDefinedError)
          end

          it "allows policy to be injected" do
            new_policy = OpenStruct.new
            controller.policy = new_policy

            expect(controller.policy(post)).to eq new_policy
          end
        end

        describe ".policy_scope" do
          it "returns an instantiated policy scope" do
            expect(controller.policy_scope(scope_const::Post)).to eq :published
          end

          it "throws an exception if the given policy can't be found" do
            expect { controller.policy_scope(scope_const::Article) }.to raise_error(Pundit::NotDefinedError)
          end

          it "allows policy_scope to be injected" do
            new_scope = OpenStruct.new
            controller.policy_scope = new_scope

            expect(controller.policy_scope(post)).to eq new_scope
          end
        end
      end
    end
  end
end